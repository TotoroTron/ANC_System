Library xpm;
use xpm.vcomponents.all;

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.anc_package.ALL;

ENTITY LMS_Update_FSM IS
    GENERIC( L : integer := 12; W : integer := 1); --length, width
    PORT( 
        clk_anc 	: IN  std_logic; --10Khz ANC System Clock
        clk_dsp		: IN  std_logic; --125Mhz FPGA Clock Pin
        clk_ila     : in std_logic;
        reset 		: IN  std_logic;
        en   		: IN  std_logic;
        input 		: IN  std_logic_vector(23 DOWNTO 0);  
        error 		: IN  std_logic_vector(23 DOWNTO 0);  
        Adapt       : IN  std_logic;
        --RAM INTERFACE
        wt_addr 		: out std_logic_vector(7 downto 0) := (others => '0');
        wt_ram_en		: out std_logic := '0'; --ram clk enable
        wt_wr_en 		: out std_logic := '0'; --ram write enable
        wt_data_in 	: in  vector_of_std_logic_vector24(0 to W-1);
        wt_data_out 	: out vector_of_std_logic_vector24(0 to W-1) := (others => (others => '0'))
    );
END LMS_Update_FSM;

ARCHITECTURE Behavioral OF LMS_Update_FSM IS
	CONSTANT R : integer := L/W; --length/width ratio
    TYPE STATE_TYPE IS (S0, S1, S2, S3, S4);
    SIGNAL STATE            	: STATE_TYPE := S0;
    SIGNAL NEXT_STATE           : STATE_TYPE;
    SIGNAL input_signed         : signed(23 DOWNTO 0) := (others => '0');
    SIGNAL error_signed         : signed(23 DOWNTO 0) := (others => '0');
--    SIGNAL input_buffer_tmp     : vector_of_signed24(0 TO L-2) := (others => (others => '0'));
--    SIGNAL input_buffer         : vector_of_signed24(0 TO L-1) := (others => (others => '0'));
    signal s_addr				: unsigned(7 downto 0) := (others => '0');
    signal s_next_addr          : unsigned(7 downto 0) := (others => '0');
    signal idle                 : std_logic := '1';
    signal next_idle            : std_logic := '1';
    
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
	
	wt_addr <= std_logic_vector(s_addr);
	sa_addr <= std_logic_vector(s_addr);
	
--	SAMPLES_REGISTER : PROCESS (clk_anc, reset, en)
--	BEGIN
--	IF rising_edge(clk_anc) THEN
--		IF reset = '1' THEN
--			input_buffer_tmp <= (OTHERS => (others => '0'));
--		ELSIF en = '1' THEN
--			input_buffer_tmp(0) <= input_signed;
--			input_buffer_tmp(1 to L-2) <= input_buffer_tmp(0 to L-3);
--		END IF;
--	END IF;
--	END PROCESS SAMPLES_REGISTER;
	
--	input_buffer(1 to L-1) <= input_buffer_tmp;
--	input_buffer(0) <= input_signed;	

    SAMPLE_REGISTER : PROCESS( CLK_ANC )
    BEGIN
        IF RISING_EDGE(CLK_ANC) THEN
           input_signed <= signed(input);
	       error_signed <= signed(error);
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
			sample_reg <= next_sample_reg;
		END IF;
	END IF;
	END PROCESS;
    
    DSP_STATE_MACHINE : PROCESS(STATE, clk_anc, adapt, idle, s_addr, wt_data_in, error_signed, input_signed, sample_reg)
        variable weight_in 		: vector_of_signed24(0 to W-1) := (others => (others => '0'));
        variable weight_out 	: vector_of_signed25(0 to W-1) := (others => (others => '0'));
        variable sample_in      : vector_of_signed24(0 to W-1) := (others => (others => '0'));
        variable sample_out     : vector_of_signed24(0 to W-1) := (others => (others => '0'));
        variable leak           : signed(24 downto 0) := "0111111111111111111101110"; --fixpt25fr24 = 0.999998927116394
        variable leak_w         : vector_of_signed50(0 to W-1) := (others => (others => '0'));
        variable mu             : signed(23 downto 0) := "010000000000000000000000"; --0.25
        variable mu_err     	: signed(47 downto 0) := (others => '0'); --product of mu and error
        variable mu_err_cast    : signed(23 downto 0) := (others => '0'); --mu_err truncated 
        variable mult           : vector_of_signed48(0 to W-1) := (others => (others => '0')); --product of mu_error and weight_in
        variable mult_cast      : vector_of_signed24(0 to W-1) := (others => (others => '0')); --mult0 truncated 
        variable data_select    : signed(23 downto 0) := (others => '0');
    BEGIN
        next_idle <= idle;
        s_next_addr <= s_addr;
        next_sample_reg <= sample_reg;
        wt_data_out <= (others => (others => '0'));
        sa_data_out <= (others => (others => '0'));
        weight_in := (others => (others => '0'));
        mult := (others => (others => '0'));
        mult_cast := (others => (others => '0'));
        leak_w := (others => (others => '0'));
        mu_err := (others => '0');
        mu_err_cast := (others => '0');
        sample_in := (others => (others => '0'));
        sample_out := (others => (others => '0'));
        data_select := (others => '0');
        
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
                next_idle <= '0';
                NEXT_STATE <= S1;
            END IF;
        WHEN S1 => --initiate read from memory (read latency = 1)
            wt_ram_en <= '1'; wt_wr_en <= '0';
            sa_ram_en <= '1'; sa_wr_en <= "0"; 
            NEXT_STATE <= S2;
        WHEN S2 =>
            wt_ram_en <= '0'; wt_wr_en <= '0';
            sa_ram_en <= '0'; sa_wr_en <= "0"; 
            NEXT_STATE <= S3;
        WHEN S3 => --data from memory clocked-in, initiate write to memory
            wt_ram_en <= '1'; wt_wr_en <= '1';
            sa_ram_en <= '1'; sa_wr_en <= "1"; 
            mu_err := mu * error_signed; --mu * error
            mu_err_cast := mu_err(47 downto 24); --truncate
            
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
                    mult(i) := mu_err_cast * data_select;
                    mult_cast(i) := mult(i)(47 downto 24);
                else
                    mult(i) := mu_err_cast * sample_in(i);
                    mult_cast(i) := mult(i)(47 downto 24);
                end if;
            end loop;
            
            if adapt = '1' then
                for i in 0 to W-1 loop
--                leak_w(i) := leak * resize(weight_in(i),25);
--                weight_out(i) := resize(leak_w(i)(47 downto 24),25) + resize(mult_cast(i),25);
                weight_out(i) := resize(weight_in(i),25) + resize(mult_cast(i),25);
                end loop;
            else
                for i in 0 to W-1 loop
                weight_out(i) := resize(weight_in(i),25);
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
            
            NEXT_STATE <= S4;
        WHEN S4 => --increment address
            wt_ram_en <= '0'; wt_wr_en <= '0';
            sa_ram_en <= '0'; sa_wr_en <= "0"; 
            IF s_addr < R-1 THEN
                s_next_addr <= s_addr + 1;
                NEXT_STATE <= S1;
            ELSIF s_addr = R-1 THEN
                s_next_addr <= (others => '0');
                NEXT_STATE <= S0;
            END IF;
        END CASE;
    END PROCESS;
	
-- xpm_memory_spram: Single Port RAM
-- Xilinx Parameterized Macro, version 2019.2
INPUT_BUFFER_STORAGE : for i in 0 to W-1 generate
xpm_memory_spram_inst : xpm_memory_spram
    generic map (
    ADDR_WIDTH_A => 8, -- DECIMAL
    AUTO_SLEEP_TIME => 0, -- DECIMAL
    BYTE_WRITE_WIDTH_A => 24, -- DECIMAL
    CASCADE_HEIGHT => 0, -- DECIMAL
    ECC_MODE => "no_ecc", -- String
    MEMORY_INIT_FILE => "none", -- String
    MEMORY_INIT_PARAM => "0", -- String
    MEMORY_OPTIMIZATION => "true", -- String
    MEMORY_PRIMITIVE => "auto", -- String
    MEMORY_SIZE => 6144, -- DECIMAL
    MESSAGE_CONTROL => 0, -- DECIMAL
    READ_DATA_WIDTH_A => 24, -- DECIMAL
    READ_LATENCY_A => 1, -- DECIMAL
    READ_RESET_VALUE_A => "0", -- String
    RST_MODE_A => "SYNC", -- String
    SIM_ASSERT_CHK => 0, -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
    USE_MEM_INIT => 1, -- DECIMAL
    WAKEUP_TIME => "disable_sleep", -- String
    WRITE_DATA_WIDTH_A => 24, -- DECIMAL
    WRITE_MODE_A => "read_first" -- String
)
port map (
    dbiterra => dbiterra,
    douta => sa_data_in(i),
    sbiterra => sbiterra,
    addra => sa_addr,
    clka => clk_dsp,
    dina => sa_data_out(i),
    ena => sa_ram_en,
    injectdbiterra => injectdbiterra,
    injectsbiterra => injectsbiterra,
    regcea => regcea,
    rsta => reset,
    sleep => sleep,
    wea => sa_wr_en
    );
end generate;
-- End of xpm_memory_spram_inst instantiation
	
END ARCHITECTURE;