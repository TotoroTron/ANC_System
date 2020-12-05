LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.top_level_pkg.ALL;

ENTITY LMS_Filter_FSM IS
  GENERIC( L : integer := 12); --length
  PORT( 
		clk_anc 	: IN  std_logic; --10Khz ANC System Clock
		clk_dsp		: IN  std_logic; --125Mhz FPGA Clock Pin
        reset 		: IN  std_logic;
        en   		: IN  std_logic;
        input 		: IN  std_logic_vector(23 DOWNTO 0);  
        desired		: IN  std_logic_vector(23 DOWNTO 0);  
        Adapt       : IN  std_logic;
		--RAM INTERFACE
		addr 		: out std_logic_vector(7 downto 0) := (others => '0');
		ram_en		: out std_logic := '0'; --ram clk enable
		wr_en 		: out std_logic := '0'; --ram write enable
		data_in 	: in  std_logic_vector(23 downto 0);
		data_out 	: out std_logic_vector(23 downto 0) := (others => '0');
		data_valid 	: out std_logic := '0'
        );
END LMS_Filter_FSM;

ARCHITECTURE Behavioral OF LMS_Filter_FSM IS
	TYPE STATE_TYPE IS (S0, S1, S2, S3);
	SIGNAL STATE, NEXT_STATE 	: STATE_TYPE;
	SIGNAL input_signed         : signed(23 DOWNTO 0) := (others => '0');
	SIGNAL desired_signed       : signed(23 DOWNTO 0) := (others => '0');
	SIGNAL input_buffer         : vector_of_signed24(0 TO L-1) := (others => (others => '0'));
	SIGNAL s_addr				: unsigned(7 downto 0) := (others => '0');
BEGIN
	
	input_signed <= signed(input);
	desired_signed <= signed(desired);
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
		variable v_input		: signed(23 downto 0) := (others => '0');
		variable weight_in 		: signed(23 downto 0) := (others => '0');
		variable weight_out 	: signed(23 downto 0) := (others => '0');
		variable mu             : signed(23 downto 0) := "001000000000000000000000";
		variable mu_err     	: signed(47 downto 0) := (others => '0'); --product of mu and error
		variable mu_err_cast    : signed(23 downto 0) := (others => '0'); --mu_err truncated 
		variable mult0          : signed(47 downto 0) := (others => '0'); --product of mu_error and weight_in
		variable mult0_cast     : signed(23 downto 0) := (others => '0'); --mult0 truncated 
		variable mult1			: signed(47 downto 0) := (others => '0');
		variable mult1_cast		: signed(23 downto 0) := (others => '0');
		variable error			: signed(23 downto 0) := (others => '0');
	BEGIN
		CASE STATE IS
		WHEN S0 => --initial state
			ram_en <= '0'; wr_en <= '0'; data_valid <= '0';
			s_addr <= (others => '0');
			data_out <= (others => '0');
			IF clk_anc = '1' THEN NEXT_STATE <= S0;
			ELSIF clk_anc = '0' THEN NEXT_STATE <= S1; END IF;
		WHEN S1 => --initiate read from memory (read latency = 1)
			ram_en <= '1'; wr_en <= '0'; data_valid <= '0';
			NEXT_STATE <= S2;
		WHEN S2 => --clock-in data from memory, initiate write to memory
			ram_en <= '1'; wr_en <= '1'; data_valid <= '1';
			v_input		:= input_buffer(to_integer(s_addr));
			weight_in 	:= signed(data_in);
			mult0 		:= weight_in * v_input; --y(n) = w(n-1)*u(n)
			mult0_cast 	:= mult0(47 downto 24);
			error 		:= desired_signed - mult0_cast; --e(n) = d(n) - y(n)
			mu_err 		:= mu * error; -- mu * e(n)
			mu_err_cast := mu_err(47 downto 24);
			mult1 		:= mu_err_cast * v_input; --mu*e(n)*u(n)
			mult1_cast	:= mult1(47 downto 24);
			if adapt = '1' then
				weight_out	:= weight_in + mult1_cast;
			elsif adapt = '0' then
				weight_out := weight_in; --no change
			end if;
			NEXT_STATE <= S3;
		WHEN S3 => --written data is valid for filter usage, increment address
			ram_en <= '0'; wr_en <= '0'; data_valid <= '0';
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