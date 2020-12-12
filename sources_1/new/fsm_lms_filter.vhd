LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.top_level_pkg.ALL;

ENTITY LMS_Filter_FSM IS
  GENERIC( L : integer := 24; W : integer := 2); --length, width
  PORT( 
		clk_anc 	: IN  std_logic; --10Khz ANC System Clock
		clk_dsp		: IN  std_logic; --125Mhz FPGA Clock Pin
		clk_ila   : in std_logic;
        reset 		: IN  std_logic;
        en   		: IN  std_logic;
        input 		: IN  std_logic_vector(23 DOWNTO 0);  
        desired		: IN  std_logic_vector(23 DOWNTO 0);  
        Adapt       : IN  std_logic;
		--RAM INTERFACE
		addr 		: out std_logic_vector(7 downto 0) := (others => '0');
		ram_en		: out std_logic := '0'; --ram clk enable
		wr_en 		: out std_logic := '0'; --ram write enable
		data_in 	: in  vector_of_std_logic_vector24(0 to W-1);
		data_out 	: out vector_of_std_logic_vector24(0 to W-1) := (others => (others => '0'));
		data_valid 	: out std_logic := '0'
        );
END LMS_Filter_FSM;

ARCHITECTURE Behavioral OF LMS_Filter_FSM IS
    CONSTANT R : integer := L/W; --length/width ratio
	TYPE STATE_TYPE IS (S0, S1, S2, S3, S4, S5, S6, S7, S8);
	SIGNAL STATE                : STATE_TYPE := S0;
	SIGNAL NEXT_STATE 	        : STATE_TYPE;
	SIGNAL input_signed         : signed(23 DOWNTO 0) := (others => '0');
	SIGNAL desired_signed       : signed(23 DOWNTO 0) := (others => '0');
	SIGNAL input_buffer_tmp     : vector_of_signed24(0 TO L-2) := (others => (others => '0'));
	SIGNAL input_buffer         : vector_of_signed24(0 TO L-1) := (others => (others => '0'));
	SIGNAL s_addr				: unsigned(7 downto 0) := (others => '0');
	SIGNAL s_next_addr	        : unsigned(7 downto 0) := (others => '0');
	signal idle : std_logic := '0';
	signal next_idle : std_logic := '0';
    signal s_sum               : signed(52 downto 0) := (others => '0');
	signal s_next_sum          : signed(52 downto 0) := (others => '0');
	signal accu_cast : signed(23 downto 0) := (others => '0');
BEGIN
	
	input_signed <= signed(input);
	desired_signed <= signed(desired);
	addr <= std_logic_vector(s_addr);
	
	SAMPLES_REGISTER : PROCESS (clk_anc, reset, en)
	BEGIN
	IF rising_edge(clk_anc) THEN
		IF reset = '1' THEN
			input_buffer_tmp <= (OTHERS => (others => '0'));
		ELSIF en = '1' THEN
		    input_buffer_tmp(0) <= input_signed;
			input_buffer_tmp(1 to L-2) <= input_buffer_tmp(0 to L-3);
		END IF;
	END IF;
	END PROCESS SAMPLES_REGISTER;
	
    input_buffer(1 to L-1) <= input_buffer_tmp;
	input_buffer(0) <= input_signed;
	
	DSP_STATE_REGISTER : PROCESS(clk_dsp, reset, en)
	BEGIN
	IF rising_edge(clk_dsp) THEN
		IF reset = '1' THEN
			STATE <= S0;
			idle <= '1';
			s_addr <= (others => '0');			
		ELSIF en = '1' THEN
			STATE <= NEXT_STATE;
			idle <= next_idle;
			s_addr <= s_next_addr;
			s_sum <= s_next_sum;			
		END IF;
	END IF;
	END PROCESS;
	
    DSP_STATE_MACHINE : PROCESS(STATE, clk_anc, idle, s_addr, data_in, input_buffer)
        variable weight_in 		: vector_of_signed24(0 to W-1) := (others => (others => '0'));
        variable weight_out 	: vector_of_signed25(0 to W-1) := (others => (others => '0'));
        variable mu             : signed(23 downto 0) := "001000000000000000000000";
        variable mu_err     	: signed(47 downto 0) := (others => '0'); --product of mu and error
        variable mu_err_cast    : signed(23 downto 0) := (others => '0'); --mu_err truncated
        variable mu_err_in     	: vector_of_signed48(0 to W-1) := (others => (others => '0')); --mu * error * input
        variable mu_err_in_cast : vector_of_signed24(0 to W-1) := (others => (others => '0'));
        
        variable mult           : vector_of_signed48(0 to W-1) := (others => (others => '0')); --product of mu_error and weight_in
        variable mult_cast      : vector_of_signed53(0 to W-1) := (others => (others => '0')); --mult0 truncated 
        variable error			: signed(24 downto 0) := (others => '0');
        variable error_cast     : signed(23 downto 0) := (others => '0');
        variable accumulator    : signed(52 downto 0) := (others => '0');
        variable s_sum_cast     : signed(23 downto 0) := (others => '0');
    BEGIN
        --state circuit S1, S2, S3 calculate the filter's output
        --state circuit S4, S5, S6 calculate the new weight vector
        next_idle <= idle;
        s_next_addr <= s_addr;
        s_next_sum <= s_sum;
        weight_in := (others => (others => '0'));
        mult := (others => (others => '0'));
        mult_cast := (others => (others => '0'));
        accumulator := (others => '0');    
        mu_err := (others => '0');
        mu_err_cast := (others => '0');      
        mu_err_in := (others => (others => '0'));
        mu_err_in_cast := (others => (others => '0'));  
        s_sum_cast := (others => '0');
        
        CASE STATE IS
        WHEN S0 => --initial state
            ram_en <= '0'; wr_en <= '0';
            s_next_addr <= (others => '0');
            data_out <= (others => (others => '0'));
            NEXT_STATE <= S0;
            IF clk_anc = '1' THEN
                next_idle <= '1';
            ELSIF clk_anc = '0' AND idle = '1' THEN
                s_next_sum <= (others => '0');
                next_idle <= '0';
                NEXT_STATE <= S1;
            END IF;
        WHEN S1 => --initiate read from memory (read latency = 1)
            ram_en <= '1'; wr_en <= '0';
            NEXT_STATE <= S2;
        WHEN S2 => --wait for read latency
            ram_en <= '0'; wr_en <= '0';
            NEXT_STATE <= S3;
        WHEN S3 => --clock-in data from memory, increment address
            ram_en <= '0'; wr_en <= '0';
            accumulator := s_sum;
            for i in 0 to W-1 loop
                weight_in(i) := signed(data_in(i));
                mult(i) := weight_in(i) * input_buffer( (R*i) + to_integer(s_addr) );
                mult_cast(i) := resize(mult(i), 53);
                accumulator := accumulator + mult_cast(i); --cascading adder risks timing failure
            end loop;
            s_next_sum <= accumulator;
            NEXT_STATE <= S4;
        WHEN S4 =>
            ram_en <= '0'; wr_en <= '0';
            IF s_addr < R-1 THEN
                s_next_addr <= s_addr + 1;
                NEXT_STATE <= S1;
            ELSIF s_addr = R-1 THEN
                s_next_addr <= (others => '0');
                NEXT_STATE <= S5;
            END IF;
        WHEN S5 => --initiate read from memory (read latency = 1)
            ram_en <= '1'; wr_en <= '0';
            NEXT_STATE <= S6;
        WHEN S6 => --wait for read latency
            ram_en <= '0'; wr_en <= '0';
            NEXT_STATE <= S7;
        WHEN S7 => --data from memory clocked-in, initiate write memory
            ram_en <= '1'; wr_en <= '1';
            s_sum_cast      := s_sum(47 downto 24);
            error 		    := resize(desired_signed,25) - resize(s_sum_cast,25); --e(n) = d(n) - y(n)
            error_cast      := error(23 downto 0);
            mu_err 		    := mu * error_cast; -- mu * e(n)
            mu_err_cast     := mu_err(47 downto 24);
            
            for i in 0 to W-1 loop
                weight_in(i) := signed(data_in(i));
                mu_err_in(i) := mu_err_cast * input_buffer( (R*i) + to_integer(s_addr) ); -- mu * e(n) * u(n)
                mu_err_in_cast(i)   := mu_err_in(i)(47 downto 24);
            end loop;
            
            if adapt = '1' then
                for i in 0 to W-1 loop
                weight_out(i)	:= resize(weight_in(i), 25) + resize(mu_err_in_cast(i), 25); --w(n) = w(n-1) + mu*e(n)*u(n)
                end loop;
            else
                for i in 0 to W-1 loop 
                weight_out(i)   := resize(weight_in(i), 25); --no change: w(n) = w(n-1)
                end loop;
            end if;
            
            for i in 0 to W-1 loop
                data_out(i) <= std_logic_vector(weight_out(i)(23 downto 0));
            end loop;
            
            NEXT_STATE <= S8;
        WHEN S8 => --wait for write latency
            ram_en <= '0'; wr_en <= '0'; --data_valid <= '1';
            IF s_addr < R-1 THEN
                s_next_addr <= s_addr + 1;
                NEXT_STATE <= S5;
            ELSIF s_addr = R-1 THEN
                s_next_addr <= (others => '0');
                NEXT_STATE <= S0;
            END IF;            
        END CASE;
    END PROCESS;
	
END ARCHITECTURE;