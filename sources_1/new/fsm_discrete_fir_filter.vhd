LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.top_level_pkg.ALL;

ENTITY Discrete_FIR_Filter_FSM IS
	GENERIC( L : integer := 12); --length
	PORT(
		clk_anc 	: IN  std_logic; --10Khz ANC System Clock
		clk_dsp		: IN  std_logic; --125Mhz FPGA Clock Pin
		reset 		: IN  std_logic;
        en   		: IN  std_logic;
        input 		: IN  std_logic_vector(23 DOWNTO 0); 
		output 		: out std_logic_vector(23 downto 0) := (others => '0');
		--RAM INTERFACE
		addr 		: out std_logic_vector(7 downto 0) := (others => '0');
		ram_en 		: out std_logic := '0';
		wr_en		: out std_logic := '0';
		data_in 	: in  std_logic_vector(23 downto 0);
		data_valid 	: in  std_logic
	);
END Discrete_FIR_Filter_FSM;

ARCHITECTURE Behavioral OF Discrete_FIR_Filter_FSM IS
	TYPE STATE_TYPE IS (S0, S1, S2, S3);
	SIGNAL STATE, NEXT_STATE 	: STATE_TYPE;
	SIGNAL input_signed 		: signed(23 downto 0) := (others => '0');
	SIGNAL input_buffer			: vector_of_signed24(0 to L-1) := (others => (others => '0'));
	SIGNAL s_addr				: unsigned(7 downto 0) := (others => '0');
BEGIN
	
	input_signed <= signed(input);
	addr <= std_logic_vector(s_addr);
	
	SAMPLES_REGISTER : PROCESS (clk_anc)
	BEGIN
	IF rising_edge(clk_anc) THEN
		IF reset = '1' THEN
			input_buffer <= (OTHERS => (others => '0'));
		ELSIF en = '1' THEN
			input_buffer(1 to L-1) <= input_buffer(0 to L-2);
			input_buffer(0) <= input_signed;
		END IF;
	END IF;
	END PROCESS SAMPLES_REGISTER;
	
	DSP_STATE_REGISTER : PROCESS(clk_dsp)
	BEGIN
	IF rising_edge(clk_dsp) THEN
		IF reset = '1' THEN
			STATE <= S0;
		ELSIF en = '1' THEN
			STATE <= NEXT_STATE;
		END IF;
	END IF;
	END PROCESS;
	
	DSP_STATE_MACHINE : PROCESS(STATE)
		variable weight_in 		: signed(23 downto 0) := (others => '0');
		variable mult0			: signed(47 downto 0) := (others => '0');
		variable mult0_cast		: signed(23 downto 0) := (others => '0');
		variable accumulator	: signed(23 downto 0) := (others => '0');
	BEGIN
		CASE STATE IS
		WHEN S0 => --initial state
			ram_en <= '0'; wr_en <= '1';
			s_addr <= (others => '0');
			accumulator := (others => '0');
			IF data_valid = '1' THEN NEXT_STATE <= S1;
			ELSIF data_valid = '0' THEN NEXT_STATE <= S0; END IF;
		WHEN S1 => --initiate read from memory (read latency = 1)
			ram_en <= '1'; wr_en <= '0';
			NEXT_STATE <= S2;
		WHEN S2 => --clock-in data from memory
			ram_en <= '0'; wr_en <= '1';
			weight_in := signed(data_in);
			mult0 := weight_in * input_buffer(to_integer(s_addr));
			mult0_cast := mult0(47 downto 24);
			accumulator := accumulator + mult0_cast;
			output <= std_logic_vector(accumulator);
			NEXT_STATE <= S3;
		WHEN S3 => --increment address
			ram_en <= '0'; wr_en <= '1';
			IF s_addr < L-1 THEN
				s_addr <= s_addr + 1;
				NEXT_STATE <= S1;
			ELSIF s_addr = L-1 THEN
				s_addr <= (others => '0');
				NEXT_STATE <= S0;
			END IF;
		END CASE;
	END PROCESS;
END ARCHITECTURE;