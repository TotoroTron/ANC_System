
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.anc_package.ALL;
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
    CONSTANT W : integer := 3;
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
	signal esp_douta 			:	vector_of_std_logic_vector24(0 to 0) := (others => (others => '0'));
	signal esp_doutb 			:	vector_of_std_logic_vector24(0 to 0) := (others => (others => '0'));
	signal sp_douta 			:	vector_of_std_logic_vector24(0 to 0) := (others => (others => '0'));
	signal sp_doutb 			:	vector_of_std_logic_vector24(0 to 0) := (others => (others => '0'));
	signal pri_douta 			:	vector_of_std_logic_vector24(0 to 0) := (others => (others => '0'));
	signal pri_doutb 			:	vector_of_std_logic_vector24(0 to 0) := (others => (others => '0'));
	signal sbiterra 		:	std_logic := '0';
	signal sbiterrb 		:	std_logic := '0';
	signal esp_addra 			:	std_logic_vector(7 downto 0) := (others => '0');
	signal esp_addrb 			:	std_logic_vector(7 downto 0) := (others => '0');
    signal sp_addra 			:	std_logic_vector(7 downto 0) := (others => '0');
	signal sp_addrb 			:	std_logic_vector(7 downto 0) := (others => '0');
    signal pri_addra 			:	std_logic_vector(7 downto 0) := (others => '0');
	signal pri_addrb 			:	std_logic_vector(7 downto 0) := (others => '0');
	signal esp_dina 			:	vector_of_std_logic_vector24(0 to 0) := (others => (others => '0'));
	signal esp_dinb 			:	vector_of_std_logic_vector24(0 to 0) := (others => (others => '0'));
	signal sp_dina 			:	vector_of_std_logic_vector24(0 to 0) := (others => (others => '0'));
	signal sp_dinb 			:	vector_of_std_logic_vector24(0 to 0) := (others => (others => '0'));
	signal pri_dina 			:	vector_of_std_logic_vector24(0 to 0) := (others => (others => '0'));
	signal pri_dinb 			:	vector_of_std_logic_vector24(0 to 0) := (others => (others => '0'));		
	signal esp_ena 				:	std_logic := '0';
	signal esp_enb 				:	std_logic := '0';
    signal sp_ena 				:	std_logic := '0';
	signal sp_enb 				:	std_logic := '0';
    signal pri_ena 				:	std_logic := '0';
	signal pri_enb 				:	std_logic := '0';
	signal injectdbiterra	:	std_logic := '0';
	signal injectdbiterrb 	:	std_logic := '0';
	signal injectsbiterra 	:	std_logic := '0';
	signal injectsbiterrb 	:	std_logic := '0';
	signal regcea 			:	std_logic := '0';
	signal regceb 			:	std_logic := '0';
	signal sleep 			:	std_logic := '0';
	signal esp_wea 				:	std_logic_vector(0 downto 0) := "0";
	signal esp_web 				:	std_logic_vector(0 downto 0) := "0";
    signal sp_wea 				:	std_logic_vector(0 downto 0) := "0";
	signal sp_web 				:	std_logic_vector(0 downto 0) := "0";
    signal pri_wea 				:	std_logic_vector(0 downto 0) := "0";
	signal pri_web 				:	std_logic_vector(0 downto 0) := "0";
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
        adapt <= '1';

ESTIM_SEC_PATH : entity work.Discrete_FIR_Filter_FSM
generic map(L => L, W => 1)
port map(
	clk_anc 	=> clk_anc,
	clk_dsp 	=> clk_dsp,
	clk_ila     => clk_ila,
	reset 		=> reset,
	en			=> ESP_en,
	input		=> ESP_FilterIn,
	output		=> ESP_FilterOut,
	--ram interface
	wt_addr		=> esp_addrb,
	wt_ram_en		=> esp_enb,
	wt_wr_en		=> esp_web(0),
	wt_data_in		=> esp_doutb
);
    ESP_FilterIn <= sine_out_ds;
    ESP_en <= '1';
    
-- xpm_memory_tdpram: True Dual Port RAM
-- Xilinx Parameterized Macro, version 2019.2
    ESP_WEIGHTS_STORAGE : xpm_memory_tdpram
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
        douta => esp_douta(0),
        doutb => esp_doutb(0),
        sbiterra => sbiterra, --unused
        sbiterrb => sbiterrb, --unused
        addra => esp_addra,
        addrb => esp_addrb,
        clka => clk_dsp,
        clkb => clk_dsp,
        dina => esp_dina(0),
        dinb => esp_dinb(0), --unused
        ena => esp_ena,
        enb => esp_enb,
        injectdbiterra => injectdbiterra, --unused
        injectdbiterrb => injectdbiterrb, --unused
        injectsbiterra => injectsbiterra, --unused
        injectsbiterrb => injectsbiterrb, --unused
        regcea => regcea, --unused
        regceb => regceb, --unused
        rsta => reset,
        rstb => reset,
        sleep => sleep, --unused
        wea => esp_wea,
        web => esp_web
    );
    -- End of xpm_memory_tdpram_inst instantiation

SECONDARY_PATH : entity work.Discrete_FIR_Filter_FSM
generic map(L => L, W => 1)
port map(
	clk_anc 	=> clk_anc,
	clk_dsp 	=> clk_dsp,
	clk_ila     => clk_ila,
	reset 		=> reset,
	en			=> SP_en,
	input		=> SP_FilterIn,
	output		=> SP_FilterOut,
	--ram interface
	wt_addr		=> sp_addrb,
	wt_ram_en		=> sp_enb,
	wt_wr_en		=> sp_web(0),
	wt_data_in		=> sp_doutb
);
    SP_FilterIn <= ANC_FilterOut_inv;
    SP_en <= '1';
    
-- xpm_memory_tdpram: True Dual Port RAM
-- Xilinx Parameterized Macro, version 2019.2
    SP_WEIGHTS_STORAGE : xpm_memory_tdpram
    generic map (
        ADDR_WIDTH_A => 8, -- DECIMAL
        ADDR_WIDTH_B => 8, -- DECIMAL
        AUTO_SLEEP_TIME => 0, -- DECIMAL
        BYTE_WRITE_WIDTH_A => 24, -- DECIMAL
        BYTE_WRITE_WIDTH_B => 24, -- DECIMAL
        CASCADE_HEIGHT => 0, -- DECIMAL
        CLOCKING_MODE => "common_clock", -- String
        ECC_MODE => "no_ecc", -- String
        MEMORY_INIT_FILE => "sp_coeff.mem", -- String
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
        douta => sp_douta(0),
        doutb => sp_doutb(0),
        sbiterra => sbiterra, --unused
        sbiterrb => sbiterrb, --unused
        addra => sp_addra,
        addrb => sp_addrb,
        clka => clk_dsp,
        clkb => clk_dsp,
        dina => sp_dina(0),
        dinb => sp_dinb(0), --unused
        ena => sp_ena,
        enb => sp_enb,
        injectdbiterra => injectdbiterra, --unused
        injectdbiterrb => injectdbiterrb, --unused
        injectsbiterra => injectsbiterra, --unused
        injectsbiterrb => injectsbiterrb, --unused
        regcea => regcea, --unused
        regceb => regceb, --unused
        rsta => reset,
        rstb => reset,
        sleep => sleep, --unused
        wea => sp_wea,
        web => sp_web
    );
    -- End of xpm_memory_tdpram_inst instantiation
 
    PRIMARY_PATH : entity work.Discrete_FIR_Filter_FSM
generic map(L => L, W => 1)
port map(
	clk_anc 	=> clk_anc,
	clk_dsp 	=> clk_dsp,
	clk_ila     => clk_ila,
	reset 		=> reset,
	en			=> PRI_en,
	input		=> PRI_FilterIn,
	output		=> PRI_FilterOut,
	--ram interface
	wt_addr		=> pri_addrb,
	wt_ram_en		=> pri_enb,
	wt_wr_en		=> pri_web(0),
	wt_data_in		=> pri_doutb
);
    PRI_FilterIn <= sine_out_ds;
    PRI_en <= '1';
    
    
-- xpm_memory_tdpram: True Dual Port RAM
-- Xilinx Parameterized Macro, version 2019.2
    PRI_WEIGHTS_STORAGE : xpm_memory_tdpram
    generic map (
        ADDR_WIDTH_A => 8, -- DECIMAL
        ADDR_WIDTH_B => 8, -- DECIMAL
        AUTO_SLEEP_TIME => 0, -- DECIMAL
        BYTE_WRITE_WIDTH_A => 24, -- DECIMAL
        BYTE_WRITE_WIDTH_B => 24, -- DECIMAL
        CASCADE_HEIGHT => 0, -- DECIMAL
        CLOCKING_MODE => "common_clock", -- String
        ECC_MODE => "no_ecc", -- String
        MEMORY_INIT_FILE => "pri_coeff.mem", -- String
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
        douta => pri_douta(0),
        doutb => pri_doutb(0),
        sbiterra => sbiterra, --unused
        sbiterrb => sbiterrb, --unused
        addra => pri_addra,
        addrb => pri_addrb,
        clka => clk_dsp,
        clkb => clk_dsp,
        dina => pri_dina(0),
        dinb => pri_dinb(0), --unused
        ena => pri_ena,
        enb => pri_enb,
        injectdbiterra => injectdbiterra, --unused
        injectdbiterrb => injectdbiterrb, --unused
        injectsbiterra => injectsbiterra, --unused
        injectsbiterrb => injectsbiterrb, --unused
        regcea => regcea, --unused
        regceb => regceb, --unused
        rsta => reset,
        rstb => reset,
        sleep => sleep, --unused
        wea => pri_wea,
        web => pri_web
    );
    -- End of xpm_memory_tdpram_inst instantiation

    summation <= std_logic_vector( signed(PRI_FilterOut) + signed(SP_FilterOut));
    
    
end Behavioral;