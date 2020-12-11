LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.top_level_pkg.ALL;
use IEEE.NUMERIC_STD.ALL;

ENTITY Discrete_FIR_Filter_FSM IS
	GENERIC( L : integer; W : integer); --length, width
	PORT(
		clk_anc 	: IN  std_logic; --10Khz ANC System Clock
		clk_dsp		: IN  std_logic; --125Mhz FPGA Clock Pin
		clk_ila     : in std_logic;
		reset 		: IN  std_logic;
        en   		: IN  std_logic;
        input 		: IN  std_logic_vector(23 DOWNTO 0); 
		output 		: out std_logic_vector(23 downto 0) := (others => '0');
		--RAM INTERFACE
		addr 		: out std_logic_vector(7 downto 0) := (others => '0');
		ram_en 		: inout std_logic := '0';
		wr_en		: inout std_logic := '0';
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
	signal s_next_addr         : unsigned(7 downto 0) := (others => '0');
	signal s_addr_v            : std_logic_vector(23 downto 0);
	signal next_idle           : std_logic := '0';
	SIGNAL idle                 : std_logic := '0';
	SIGNAL s_accumulator         : signed(52 downto 0) := (others => '0');
	signal gnd : std_logic := '0';
	signal state_v : std_logic_vector(4 downto 0);
BEGIN

   DEBUG_SIGNALS_2 : ila_0
    PORT MAP(
        clk => clk_dsp,
        probe0 => clk_anc,
        probe1 => en,
        probe2 => state_v(0),
        probe3 => state_v(1),
        probe4 => state_v(2),
        probe5 => state_v(3),
        probe6 => state_v(4),
        probe7 => data_valid,
        probe8 => ram_en,
        probe9 => wr_en,
        probe10 => s_addr_v,
        probe11=> data_in(0)
    );
	
    DEBUG_FIR_BUFFER_1 : ila_3
    PORT MAP(
        clk     => clk_dsp,
        probe0  => std_logic_vector(input_buffer(0)),
        probe1  => std_logic_vector(input_buffer(1)),
        probe2  => std_logic_vector(input_buffer(2)),
        probe3  => std_logic_vector(input_buffer(3)),
        probe4  => std_logic_vector(input_buffer(4)),
        probe5  => std_logic_vector(input_buffer(5)),
        probe6  => std_logic_vector(input_buffer(6))
    );
	   s_addr_v <= X"0000" & std_logic_vector(s_addr);
	
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
			idle <= next_idle;
			s_addr <= s_next_addr;
		END IF;
	END IF;
	END PROCESS;
	
    DSP_STATE_MACHINE : PROCESS(STATE, clk_anc, idle, s_addr)
        variable weight_in 	    : vector_of_signed24(0 to W-1) := (others => (others => '0'));
        variable mult			: vector_of_signed48(0 to W-1) := (others => (others => '0'));
        variable mult_cast	    : vector_of_signed53(0 to W-1) := (others => (others => '0'));
        variable accumulator	: signed(52 downto 0) := (others => '0');
    BEGIN
        CASE STATE IS
        WHEN S0 => --initial state
            state_v <= "00001";
            ram_en <= '0'; wr_en <= '0';
            s_next_addr <= (others => '0');
            accumulator := (others => '0');
            IF clk_anc = '1' THEN
                next_idle <= '1';
                NEXT_STATE <= S0;
            ELSIF clk_anc = '0' AND idle = '1' THEN
                next_idle <= '0';
                NEXT_STATE <= S1;
            END IF;
        WHEN S1 => --initiate read from memory (read latency = 1)
        state_v <= "00010";
            ram_en <= '1'; wr_en <= '0';
            NEXT_STATE <= S2; --S2
        WHEN S2 => --wait for read latency
        state_v <= "00100";
            ram_en <= '0'; wr_en <= '0';
            NEXT_STATE <= S3;
        WHEN S3 => --data from memory clocked-in
        state_v <= "01000";
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
        state_v <= "10000";
            ram_en <= '0'; wr_en <= '0';
            IF s_addr < R-1 THEN
                s_next_addr <= s_addr + 1;
                NEXT_STATE <= S1;
            ELSIF s_addr = R-1 THEN
                output <= std_logic_vector(accumulator(47 downto 24)) ;
                s_next_addr <= (others => '0');
                NEXT_STATE <= S0;
            END IF;
        END CASE;
    END PROCESS;
END ARCHITECTURE;