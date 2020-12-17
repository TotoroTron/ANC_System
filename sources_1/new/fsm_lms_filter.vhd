Library xpm;
use xpm.vcomponents.all;

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.top_level_pkg.ALL;

ENTITY LMS_Filter_FSM IS
  GENERIC( L : integer := 128; W : integer := 8); --length, width
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
		wt_addr 		: out std_logic_vector(7 downto 0) := (others => '0');
		wt_ram_en		: out std_logic := '0'; --ram clk enable
		wt_wr_en 		: out std_logic := '0'; --ram write enable
		wt_data_in 	: in  vector_of_std_logic_vector24(0 to W-1);
		wt_data_out 	: out vector_of_std_logic_vector24(0 to W-1) := (others => (others => '0'))
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
	signal idle                 : std_logic := '0';
	signal next_idle            : std_logic := '0';
    signal s_sum                : signed(52 downto 0) := (others => '0');
	signal s_next_sum           : signed(52 downto 0) := (others => '0');
	signal accu_cast            : signed(23 downto 0) := (others => '0');
	
    signal sample_reg           : vector_of_signed24(0 to W-1) := (others => (others => '0'));
    signal next_sample_reg      : vector_of_signed24(0 to W-1) := (others => (others => '0'));
    signal sa_addr 		        :  std_logic_vector(7 downto 0) := (others => '0');
    signal sa_ram_en		    :  std_logic := '0'; --ram clk enable
    signal sa_wr_en 		    :  std_logic_vector(0 downto 0) := "0"; --ram write enable
    signal sa_data_in           : vector_of_std_logic_vector24(0 to W-1) := (others => (others => '0'));
    signal sa_data_out          : vector_of_std_logic_vector24(0 to W-1) := (others => (others => '0'));
    
    signal dbiterra 		: 	std_logic := '0';
	signal dbiterrb			:	std_logic := '0';
	signal doutb 			:	vector_of_std_logic_vector24(0 to W-1) := (others => (others => '0'));
	signal sbiterra 		:	std_logic := '0';
	signal sbiterrb 		:	std_logic := '0';
	signal addrb 			:	std_logic_vector(7 downto 0) := (others => '0');
	signal dinb 			:	vector_of_std_logic_vector24(0 to W-1) := (others => (others => '0'));
	signal ena 				:	std_logic := '0';
	signal enb 				:	std_logic := '0';
	signal injectdbiterra	:	std_logic := '0';
	signal injectdbiterrb 	:	std_logic := '0';
	signal injectsbiterra 	:	std_logic := '0';
	signal injectsbiterrb 	:	std_logic := '0';
	signal regcea 			:	std_logic := '0';
	signal regceb 			:	std_logic := '0';
	signal sleep 			:	std_logic := '0';
	signal web 				:	std_logic_vector(0 downto 0) := "0";
BEGIN
	
--	input_signed <= signed(input);
--	desired_signed <= signed(desired);
	wt_addr <= std_logic_vector(s_addr);
	sa_addr <= std_logic_vector(s_addr);
	
--	SAMPLES_REGISTER : PROCESS (clk_anc, reset, en)
--	BEGIN
--	IF rising_edge(clk_anc) THEN
--		IF reset = '1' THEN
--			input_buffer_tmp <= (OTHERS => (others => '0'));
--		ELSIF en = '1' THEN
--		    input_buffer_tmp(0) <= input_signed;
--			input_buffer_tmp(1 to L-2) <= input_buffer_tmp(0 to L-3);
--		END IF;
--	END IF;
--	END PROCESS SAMPLES_REGISTER;
	
--    input_buffer(1 to L-1) <= input_buffer_tmp;
--	input_buffer(0) <= input_signed;
	
    SAMPLE_REGISTER : PROCESS( CLK_ANC )
    BEGIN
        IF RISING_EDGE(CLK_ANC) THEN
           input_signed <= signed(input);
	       desired_signed <= signed(desired);
        END IF;
    END PROCESS;
	
	DSP_STATE_REGISTER : PROCESS(clk_dsp, reset, en)
	BEGIN
	IF rising_edge(clk_dsp) THEN
		IF reset = '1' THEN
			STATE <= S0;
			idle <= '1';
			s_addr <= (others => '0');			
			sample_reg <= (others => (others => '0'));
		ELSIF en = '1' THEN
			STATE <= NEXT_STATE;
			idle <= next_idle;
			s_addr <= s_next_addr;
			s_sum <= s_next_sum;	
			sample_reg <= next_sample_reg;	
		END IF;
	END IF;
	END PROCESS;
	
    DSP_STATE_MACHINE : PROCESS(STATE, clk_anc, idle, s_addr, wt_data_in, input_signed, desired_signed, sample_reg)
        variable weight_in 		: vector_of_signed24(0 to W-1) := (others => (others => '0'));
        variable weight_out 	: vector_of_signed25(0 to W-1) := (others => (others => '0'));
        variable sample_in      : vector_of_signed24(0 to W-1) := (others => (others => '0'));
        variable sample_out     : vector_of_signed24(0 to W-1) := (others => (others => '0'));        
        variable mu             : signed(23 downto 0) := "010000000000000000000000"; --fixpt24fr24 = 0.25
        variable leak           : signed(24 downto 0) := "0111111111111111111101110"; --fixpt25fr24 = 0.999998927116394
        variable leak_w         : vector_of_signed50(0 to W-1) := (others => (others => '0'));
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
        
        variable data_select    : signed(23 downto 0) := (others => '0');
    BEGIN
        --state circuit S1, S2, S3 calculate the filter's output
        --state circuit S4, S5, S6 calculate the new weight vector
        next_idle <= idle;
        s_next_addr <= s_addr;
        s_next_sum <= s_sum;
        next_sample_reg <= sample_reg;
        wt_data_out <= (others => (others => '0'));
        sa_data_out <= (others => (others => '0'));
        weight_in := (others => (others => '0'));
        mult := (others => (others => '0'));
        mult_cast := (others => (others => '0'));
        accumulator := (others => '0');
        leak_w := (others => (others => '0'));
        mu_err := (others => '0');
        mu_err_cast := (others => '0');      
        mu_err_in := (others => (others => '0'));
        mu_err_in_cast := (others => (others => '0'));  
        s_sum_cast := (others => '0');
        
        CASE STATE IS
        WHEN S0 => --initial state
            wt_ram_en <= '0'; wt_wr_en <= '0';
            sa_ram_en <= '0'; sa_wr_en <= "0"; 
            s_next_addr <= (others => '0');
            wt_data_out <= (others => (others => '0'));
            NEXT_STATE <= S0;
            IF clk_anc = '1' THEN
                next_idle <= '1';
            ELSIF clk_anc = '0' AND idle = '1' THEN
                s_next_sum <= (others => '0');
                next_idle <= '0';
                NEXT_STATE <= S1;
            END IF;
        WHEN S1 => --initiate read from memory (read latency = 1)
            wt_ram_en <= '1'; wt_wr_en <= '0';
            sa_ram_en <= '1'; sa_wr_en <= "0"; 
            NEXT_STATE <= S2;
        WHEN S2 => --wait for read latency
            wt_ram_en <= '0'; wt_wr_en <= '0';
            sa_ram_en <= '0'; sa_wr_en <= "0"; 
            NEXT_STATE <= S3;
        WHEN S3 => --clock-in data from memory, increment address
            wt_ram_en <= '0'; wt_wr_en <= '0';
            sa_ram_en <= '1'; sa_wr_en <= "1"; 
            accumulator := s_sum;
            for i in 0 to W-1 loop
                weight_in(i) := signed(wt_data_in(i));
                sample_in(i) := signed(sa_data_in(i));
                if i = 0 then
                    if s_addr = 0 then
                        data_select := input_signed;
                    else
                        data_select := sample_in(i);
                    end if;
                    mult(i) := weight_in(i) * data_select;
                    mult_cast(i) := resize(mult(i), 53);
                else
                    mult(i) := weight_in(i) * sample_in(i);
                    mult_cast(i) := resize(mult(i), 53);
                end if;
                accumulator := accumulator + mult_cast(i); --cascading adder risks timing failure
            end loop;
            
            s_next_sum <= accumulator;

            
            NEXT_STATE <= S4;
        WHEN S4 =>
            wt_ram_en <= '0'; wt_wr_en <= '0';
            sa_ram_en <= '0'; sa_wr_en <= "0"; 
            IF s_addr < R-1 THEN
                s_next_addr <= s_addr + 1;
                NEXT_STATE <= S1;
            ELSIF s_addr = R-1 THEN
                s_next_addr <= (others => '0');
                NEXT_STATE <= S5;
            END IF;
        WHEN S5 => --initiate read from memory (read latency = 1)
            wt_ram_en <= '1'; wt_wr_en <= '0';
            sa_ram_en <= '1'; sa_wr_en <= "0"; 
            NEXT_STATE <= S6;
        WHEN S6 => --wait for read latency
            wt_ram_en <= '0'; wt_wr_en <= '0';
            sa_ram_en <= '0'; sa_wr_en <= "0"; 
            NEXT_STATE <= S7;
        WHEN S7 => --data from memory clocked-in, initiate write memory
            wt_ram_en <= '1'; wt_wr_en <= '1';
            sa_ram_en <= '1'; sa_wr_en <= "1"; 
            s_sum_cast      := s_sum(47 downto 24);
            error 		    := resize(desired_signed,25) - resize(s_sum_cast,25); --e(n) = d(n) - y(n)
            error_cast      := error(23 downto 0);
            mu_err 		    := mu * error_cast; -- mu * e(n)
            mu_err_cast     := mu_err(47 downto 24);
            
            for i in 0 to W-1 loop
                weight_in(i) := signed(wt_data_in(i));
                sample_in(i) := signed(sa_data_in(i));
                next_sample_reg(i) <= sample_in(i);
                if i = 0 then
                    if s_addr = 0 then
                        data_select := input_signed;
                    else
                        data_select := sample_in(i);
                    end if;
                    mu_err_in(i) := mu_err_cast * data_select; -- mu * e(n) * u(n)
                    mu_err_in_cast(i) := mu_err_in(i)(47 downto 24);
                else
                    mu_err_in(i) := mu_err_cast * sample_in(i); -- mu * e(n) * u(n)
                    mu_err_in_cast(i) := mu_err_in(i)(47 downto 24);
                end if;
            end loop;
            
            if adapt = '1' then
                for i in 0 to W-1 loop
                leak_w(i) := leak * resize(weight_in(i),25);
                weight_out(i) := resize(leak_w(i)(47 downto 24),25) + resize(mu_err_in_cast(i),25);
                --weight_out(i)	:= resize(weight_in(i), 25) + resize(mu_err_in_cast(i), 25); --w(n) = w(n-1) + mu*e(n)*u(n)
                end loop;
            else
                for i in 0 to W-1 loop 
                weight_out(i)   := resize(weight_in(i), 25); --no change: w(n) = w(n-1)
                end loop;
            end if;
            
            for i in 0 to W-1 loop
                if i = 0 then
                    if s_addr = 0 then sample_out(i) := (others => '0');
                    elsif s_addr = 1 then sample_out(i) := input_signed;
                    else sample_out(i) := sample_reg(i);
                    end if;
                else
                    if s_addr = 0 then sample_out(i) := sample_reg(i-1);
                    else sample_out(i) := sample_reg(i);
                    end if;
                end if;
            end loop;
            
            for i in 0 to W-1 loop
                wt_data_out(i) <= std_logic_vector(weight_out(i)(23 downto 0)); --output value to memory
                sa_data_out(i) <= std_logic_vector(sample_out(i)(23 downto 0));
            end loop;
            
            NEXT_STATE <= S8;
        WHEN S8 => --wait for write latency
            wt_ram_en <= '0'; wt_wr_en <= '0';
            sa_ram_en <= '0'; sa_wr_en <= "0"; 
            IF s_addr < R-1 THEN
                s_next_addr <= s_addr + 1;
                NEXT_STATE <= S5;
            ELSIF s_addr = R-1 THEN
                s_next_addr <= (others => '0');
                NEXT_STATE <= S0;
            END IF;            
        END CASE;
    END PROCESS;
INPUT_BUFFER_STORAGE : for i in 0 to W-1 generate
    TDPRAM : xpm_memory_tdpram
    generic map (
        ADDR_WIDTH_A => 8, -- DECIMAL
        ADDR_WIDTH_B => 8, -- DECIMAL
        AUTO_SLEEP_TIME => 0, -- DECIMAL
        BYTE_WRITE_WIDTH_A => 24, -- DECIMAL
        BYTE_WRITE_WIDTH_B => 24, -- DECIMAL
        CASCADE_HEIGHT => 0, -- DECIMAL
        CLOCKING_MODE => "common_clock", -- String
        ECC_MODE => "no_ecc", -- String
        MEMORY_INIT_FILE => "none", -- String
        MEMORY_INIT_PARAM => "0", -- String
        MEMORY_OPTIMIZATION => "true", -- String
        MEMORY_PRIMITIVE => "auto", -- String
        MEMORY_SIZE => 6144, -- DECIMAL (measured in bits)
        MESSAGE_CONTROL => 0, -- DECIMAL
        READ_DATA_WIDTH_A => 24, -- DECIMAL
        READ_DATA_WIDTH_B => 24, -- DECIMAL
        READ_LATENCY_A => 1, -- DECIMAL
        READ_LATENCY_B => 1, -- DECIMAL
        READ_RESET_VALUE_A => "0", -- String
        READ_RESET_VALUE_B => "0", -- String
        RST_MODE_A => "SYNC", -- String
        RST_MODE_B => "SYNC", -- String
        SIM_ASSERT_CHK => 0, -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
        USE_EMBEDDED_CONSTRAINT => 0, -- DECIMAL
        USE_MEM_INIT => 1, -- DECIMAL
        WAKEUP_TIME => "disable_sleep", -- String
        WRITE_DATA_WIDTH_A => 24, -- DECIMAL
        WRITE_DATA_WIDTH_B => 24, -- DECIMAL
        WRITE_MODE_A => "no_change", -- String
        WRITE_MODE_B => "no_change" -- String
    ) port map (
        dbiterra => dbiterra, --unused
        dbiterrb => dbiterrb, --unused
        douta => sa_data_out(i),
        doutb => doutb(i),
        sbiterra => sbiterra, --unused
        sbiterrb => sbiterrb, --unused
        addra => sa_addr,
        addrb => addrb,
        clka => clk_dsp,
        clkb => clk_dsp,
        dina => sa_data_in(i),
        dinb => dinb(i), --unused
        ena => sa_ram_en,
        enb => enb,
        injectdbiterra => injectdbiterra, --unused
        injectdbiterrb => injectdbiterrb, --unused
        injectsbiterra => injectsbiterra, --unused
        injectsbiterrb => injectsbiterrb, --unused
        regcea => regcea, --unused
        regceb => regceb, --unused
        rsta => reset,
        rstb => reset,
        sleep => sleep, --unused
        wea => sa_wr_en,
        web => web
    );
end generate;	
END ARCHITECTURE;