
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.top_level_pkg.ALL;
Library xpm;
use xpm.vcomponents.all;

entity lms_update_fsm_testbench is
--  Port ( );
end lms_update_fsm_testbench;
--
architecture Behavioral of lms_update_fsm_testbench is
    signal clk, clk_5Mhz : std_logic;
    signal clk_dsp : std_logic := '0';
    signal clk_anc: std_logic := '0';
    signal clk_ila : std_logic := '0';
    signal clk_sine : std_logic := '0';
    signal sine_en : std_logic := '0';
    signal reset : std_logic := '0';
    signal clk_enable: std_logic := '0';
    signal adapt: std_logic := '0';
    signal enable: std_logic := '0';
    signal clk_div_out : std_logic := '0';
    signal clk_41Khz : std_logic:='0';
    signal sine_out, sine_out_ds, rand_out, rand_amp : std_logic_vector(23 downto 0) := (others => '0');
    signal count : unsigned(8 downto 0) := (others => '0');
    
    constant t1 : time := 8ns;
    
    CONSTANT L : integer := 12;
    CONSTANT W : integer := 1;
    CONSTANT R : integer := L/W; --length/width ratio
        
    signal LMSU_input, LMSU_error: std_logic_vector(23 downto 0) := (others => '0');
    
    signal ESP_FilterIn, ESP_FilterOut: std_logic_vector(23 downto 0) := (others => '0');
    signal ESP_Coeff : vector_of_std_logic_vector24(0 to 11) := (others => (others => '0'));
    signal ESP_en : std_logic := '0';
    
    signal SP_FilterIn, SP_FilterOut: std_logic_vector(23 downto 0) := (others => '0');
    signal SP_Coeff : vector_of_std_logic_vector24(0 to 11) := (others => (others => '0'));
    signal SP_en : std_logic := '0';
    
    signal ANC_FilterIn, ANC_FilterOut : std_logic_vector(23 downto 0) := (others => '0');
    signal ANC_en : std_logic := '0';
    
    signal PRI_FilterIn, PRI_FilterOut : std_logic_vector(23 downto 0) := (others => '0');
    signal PRI_coeff : vector_of_std_logic_vector24(0 to 11) := (others => (others => '0'));
    signal PRI_en : std_logic := '0';
    
    signal tmp : vector_of_std_logic_vector24(0 to 15) := (others => (others => '0'));
    signal summation : std_logic_vector(23 downto 0) := (others => '0');
    signal ANC_FilterOut_inv : std_logic_vector(23 downto 0) := (others => '0');
    
    signal dbiterra 		: 	std_logic := '0';
	signal dbiterrb			:	std_logic := '0';
	signal douta 			:	vector_of_std_logic_vector24(0 to W-1) := (others => (others => '0'));
	signal doutb 			:	vector_of_std_logic_vector24(0 to W-1) := (others => (others => '0'));
	signal sbiterra 		:	std_logic := '0';
	signal sbiterrb 		:	std_logic := '0';
	signal addra 			:	std_logic_vector(7 downto 0) := (others => '0');
	signal addrb 			:	std_logic_vector(7 downto 0) := (others => '0');
	signal dina 			:	vector_of_std_logic_vector24(0 to W-1) := (others => (others => '0'));
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
	signal wea 				:	std_logic_vector(0 downto 0) := "0";
	signal web 				:	std_logic_vector(0 downto 0) := "0";
	signal lms_data_valid	:	std_logic := '0';
begin

    CLOCK_ANC : process
    begin
        clk <= '0';
        wait for t1/2;
        clk <= '1';
        wait for t1/2;
    end process;

    SINE_WAVE_150 : entity work.sine_generator(amplitude_25) --150Hz sine output, 1K sample period
    port map(clk => clk_sine, reset => reset, clk_enable => sine_en, Out1 => sine_out);
    SINE_en <= '1';
    SINE_BUFFER : process(clk_anc) begin
        if rising_edge(clk_anc) then
            sine_out_ds <= sine_out;
        end if;
    end process;
    PMOD_CLK : clk_wiz_0
    port map(clk_in1 => clk, clk_out1 => clk_5Mhz);
    COUNTER : process(clk_5Mhz)begin
        if rising_edge(clk_5Mhz) then
            count <= count + 1;
        end if;
    end process;
    clk_dsp <= clk_5Mhz;
    clk_anc <= count(8);
    CLK_GEN_41Khz : entity work.clk_div --15Khz drives 150Hz sine
    generic map(count => 834) port map(clk_in => clk, clk_out => clk_sine);
    
    PRIMARY_SOUND_PATH : entity work.primary_path
    generic map(L => L, W => W)
	port map(
		clk_anc 	=> clk_anc,
		clk_dsp 	=> clk_dsp,
		clk_ila    => clk_ila,
		reset 		=> reset,
		filt_enable => ANC_en,
		filt_input 	=> ANC_FilterIn,
		filt_output => ANC_FilterOut,
		algo_enable => ANC_en,
		algo_input 	=> LMSU_input,
		algo_error 	=> LMSU_error,
		algo_adapt 	=> adapt
	);
        ANC_FilterIn <= sine_out_ds;
        ANC_FilterOut_inv <= std_logic_vector(-signed(ANC_FilterOut));
        LMSU_input <= ESP_FilterOut;
        LMSU_error <= summation;
        ANC_en <= '1';
--    ESTIM_SEC_PATH : entity work.Discrete_FIR_Filter_12
--    port map(
--        clk => clk_anc,
--        reset => reset,
--        enb => ESP_en,
--        Discrete_FIR_Filter_in => ESP_FilterIn,
--        Discrete_FIR_Filter_coeff => ESP_Coeff,
--        Discrete_FIR_Filter_out => ESP_FilterOut
--    );
--        ESP_FilterIn <= sine_out_100SA;
--        ESP_en <= '1';
--        ESP_Coeff(0) <= "011101110100101111000110";-- 0.466
--        ESP_Coeff(1) <= "100010000111001010110000";-- 0.533
--            tmp(0) <= "010000011100101011000000";
--        ESP_Coeff(2) <= std_logic_vector(-signed(tmp(0)));-- -0.257
--            tmp(1) <= "010001100010010011011101";
--        ESP_Coeff(3) <= std_logic_vector(-signed(tmp(1)));-- -0.274
--            tmp(2) <= "001110110010001011010000";
--        ESP_Coeff(4) <= std_logic_vector(-signed(tmp(2)));-- -0.231
--            tmp(3) <= "001011001100110011001100";
--        ESP_Coeff(5) <= std_logic_vector(-signed(tmp(3)));-- -0.175

ESTIM_SEC_PATH : entity work.Discrete_FIR_Filter_FSM
generic map(L => L, W => W)
port map(
	clk_anc 	=> clk_anc,
	clk_dsp 	=> clk_dsp,
	clk_ila     => clk_ila,
	reset 		=> reset,
	en			=> ESP_en,
	input		=> ESP_FilterIn,
	output		=> ESP_FilterOut,
	--ram interface
	addr		=> addrb,
	ram_en		=> enb,
	wr_en		=> web(0),
	data_in		=> doutb,
	data_valid	=> lms_data_valid
);
    lms_data_valid <= NOT clk_anc;
    ESP_FilterIn <= sine_out_ds;
    ESP_en <= '1';
    
-- xpm_memory_tdpram: True Dual Port RAM
-- Xilinx Parameterized Macro, version 2019.2
GEN_WEIGHTS_STORAGE : for i in 0 to W-1 generate
    WEIGHTS_STORAGE : xpm_memory_tdpram
    generic map (
        ADDR_WIDTH_A => 8, -- DECIMAL
        ADDR_WIDTH_B => 8, -- DECIMAL
        AUTO_SLEEP_TIME => 0, -- DECIMAL
        BYTE_WRITE_WIDTH_A => 24, -- DECIMAL
        BYTE_WRITE_WIDTH_B => 24, -- DECIMAL
        CASCADE_HEIGHT => 0, -- DECIMAL
        CLOCKING_MODE => "common_clock", -- String
        ECC_MODE => "no_ecc", -- String
        MEMORY_INIT_FILE => "esp_coeff.mem", -- String
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
        douta => douta(i),
        doutb => doutb(i),
        sbiterra => sbiterra, --unused
        sbiterrb => sbiterrb, --unused
        addra => addra,
        addrb => addrb,
        clka => clk_dsp,
        clkb => clk_dsp,
        dina => dina(i),
        dinb => dinb(i), --unused
        ena => ena,
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
        wea => wea,
        web => web
    );
    -- End of xpm_memory_tdpram_inst instantiation
end generate;
            
    SECONDARY_PATH : entity work.Discrete_FIR_Filter_12
    port map(
        clk => clk_anc,
        reset => reset,
        enb => SP_en,
        Discrete_FIR_Filter_in => SP_FilterIn,
        Discrete_FIR_Filter_coeff => SP_Coeff,
        Discrete_FIR_Filter_out => SP_FilterOut
    );
        SP_FilterIn <= ANC_FilterOut_inv;
        SP_en <= '1';
        SP_Coeff(0) <= "011111010111000010100011"; -- 0.49
        SP_Coeff(1) <= "011111010111000010100011"; -- 0.49
            tmp(6) <= "010011001100110011001100";
        SP_Coeff(2) <= std_logic_vector(-signed(tmp(6))); -- -0.3
        SP_Coeff(3) <= std_logic_vector(-signed(tmp(6))); -- -0.3
            tmp(7) <= "001100110011001100110011";
        SP_Coeff(4) <= std_logic_vector(-signed(tmp(7))); -- -0.2
        SP_Coeff(5) <= std_logic_vector(-signed(tmp(7))); -- -0.2        
    
    PRIMARY_PATH : entity work.Discrete_FIR_Filter_12 --"lms filter copy in matlab"
    port map(
        clk => clk_anc,
        reset => reset,
        enb => PRI_en,
        Discrete_FIR_Filter_in => PRI_FilterIn,
        Discrete_FIR_Filter_coeff => PRI_Coeff,
        Discrete_FIR_Filter_out => PRI_FilterOut
    );
        PRI_FilterIn <= sine_out_ds;
        PRI_en <= '1';
        PRI_Coeff(0) <= "000011001100110011001100"; -- 0.05
        PRI_Coeff(1) <= (others => '0');
        PRI_Coeff(2) <= "000001010001111010111000"; -- 0.02
        PRI_Coeff(3) <= (others => '0');
        PRI_Coeff(4) <= (others => '0');
        PRI_Coeff(5) <= (others => '0');
            tmp(4) <= "001000000000000000000000"; 
        PRI_Coeff(6) <= std_logic_vector(-signed(tmp(4))); -- -0.125
        PRI_Coeff(7) <= (others => '0');
            tmp(5) <= "000011001100110011001100";
        PRI_Coeff(8) <= std_logic_vector(-signed(tmp(5))); -- -0.05 
        PRI_Coeff(9) <= (others => '0');
        PRI_Coeff(10) <= "000100110011001100110011"; -- 0.075
        PRI_Coeff(11) <= (others => '0');
        
    summation <= std_logic_vector( signed(PRI_FilterOut) + signed(SP_FilterOut));
    
    
end Behavioral;