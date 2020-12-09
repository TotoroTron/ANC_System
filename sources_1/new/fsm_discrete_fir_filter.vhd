LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.top_level_pkg.ALL;
use IEEE.NUMERIC_STD.ALL;

ENTITY Discrete_FIR_Filter_FSM IS
	GENERIC( L : integer; W : integer); --length width
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
		data_in 	: in  vector_of_std_logic_vector24(0 to W-1);
		data_valid 	: in  std_logic
	);
END Discrete_FIR_Filter_FSM;

ARCHITECTURE Behavioral OF Discrete_FIR_Filter_FSM IS
	CONSTANT R : integer := L/W; --length/width ratio
	TYPE STATE_TYPE IS (S0, S1, S2, S3, S4);
	SIGNAL STATE                : STATE_TYPE := S0;
	SIGNAL NEXT_STATE 	        : STATE_TYPE;
	SIGNAL input_signed 		: signed(23 downto 0) := (others => '0');
	SIGNAL input_buffer			: vector_of_signed24(0 to L-2) := (others => (others => '0'));
	SIGNAL s_addr				: unsigned(7 downto 0) := (others => '0');
	SIGNAL idle                 : std_logic := '0';
	--SIGNAL accumulator         : signed(52 downto 0) := (others => '0');
BEGIN
	
	input_signed <= signed(input);
	addr <= std_logic_vector(s_addr);
	
	SAMPLES_REGISTER : PROCESS (clk_anc)
	BEGIN
	IF rising_edge(clk_anc) THEN
		IF reset = '1' THEN
			input_buffer <= (OTHERS => (others => '0'));
		ELSIF en = '1' THEN
		    input_buffer(0) <= input_signed;
			input_buffer(1 to L-2) <= input_buffer(0 to L-3);
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
	
    DSP_STATE_MACHINE : PROCESS(STATE, data_valid)
        variable weight_in 	    : vector_of_signed24(0 to W-1) := (others => (others => '0'));
        variable mult			: vector_of_signed48(0 to W-1) := (others => (others => '0'));
        variable mult_cast	    : vector_of_signed53(0 to W-1) := (others => (others => '0'));
        variable accumulator	: signed(52 downto 0) := (others => '0');
        variable part_sum       : signed(52 downto 0) := (others => '0');
        
    BEGIN
        CASE STATE IS
        WHEN S0 => --initial state
            ram_en <= '0'; wr_en <= '0';
            s_addr <= (others => '0');
            accumulator := (others => '0');
            IF data_valid = '0' THEN
                idle <= '1';
                NEXT_STATE <= S0;
            ELSIF data_valid = '1' AND idle = '1' THEN
                idle <= '0';
                NEXT_STATE <= S1;
            END IF;
        WHEN S1 => --initiate read from memory (read latency = 1)
            ram_en <= '1'; wr_en <= '0';
            NEXT_STATE <= S2; --S2
        WHEN S2 => --wait for read latency
            ram_en <= '0'; wr_en <= '0';
            NEXT_STATE <= S3;
        WHEN S3 => --data from memory clocked-in
            ram_en <= '0'; wr_en <= '0';
            for i in 0 to W-1 loop
                weight_in(i) := signed(data_in(i));
                if i = 0 then
                    if s_addr = 0 then
                        mult(i) := weight_in(i) * input_signed;
                    else
                        mult(i) := weight_in(i) * input_buffer( (R*i) + to_integer(s_addr)-1 );
                    end if;
                    mult_cast(i) := resize(mult(i), 53);
                else
                    mult(i) := weight_in(i) * input_buffer( (R*i) + to_integer(s_addr)-1 );
                    mult_cast(i) := resize(mult(i), 53);
                end if;
                accumulator := accumulator + mult_cast(i); --cascading adder risks timing failure
            end loop;
            NEXT_STATE <= S4;
        WHEN S4 => --increment address
            ram_en <= '0'; wr_en <= '0';
            IF s_addr < R-1 THEN
                s_addr <= s_addr + 1;
                NEXT_STATE <= S1;
            ELSIF s_addr = R-1 THEN
                output <= std_logic_vector(accumulator(47 downto 24)) ;
                s_addr <= (others => '0');
                NEXT_STATE <= S0;
            END IF;
        END CASE;
    END PROCESS;
END ARCHITECTURE;