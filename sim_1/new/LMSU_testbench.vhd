
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.anc_package.ALL;
Library xpm;
use xpm.vcomponents.all;

entity LMSU_testbench is
--  Port ( );
end LMSU_testbench;
--
architecture Behavioral of LMSU_testbench is
    signal clk, clk_5Mhz : std_logic := '0';
    signal clk_dsp : std_logic := '0';
    signal clk_anc: std_logic := '0';
    signal clk_ila : std_logic := '0';
    signal clk_sine_150, clk_sine_200 : std_logic := '0';
    signal sine_en : std_logic := '0';
    signal reset : std_logic := '0';
    signal clk_enable: std_logic := '0';
    signal adapt: std_logic := '0';
    signal enable: std_logic := '0';
    signal clk_div_out : std_logic := '0';
    signal clk_41Khz : std_logic:='0';
    signal sine_out : std_logic_vector(23 downto 0) := (others => '0');
    signal sine_out_150: std_logic_vector(23 downto 0) := (others => '0');
    signal sine_out_200: std_logic_vector(23 downto 0) := (others => '0');
    signal sine_out_150_ds: std_logic_vector(23 downto 0) := (others => '0');
    signal sine_out_200_ds: std_logic_vector(23 downto 0) := (others => '0');
    signal count : unsigned(8 downto 0) := (others => '0');
    
    constant t1 : time := 8ns;
    
    CONSTANT L : integer := 12;
    CONSTANT W : integer := 1;
    CONSTANT R : integer := L/W; --length/width ratio
        
    signal LMSU1_input, LMSU1_error: std_logic_vector(23 downto 0) := (others => '0');
    signal LMSU1_en : std_logic := '0';
    signal LMSU2_input, LMSU2_error: std_logic_vector(23 downto 0) := (others => '0');
    signal LMSU2_en : std_logic := '0';
    signal Wanc : vector_of_std_logic_vector24(0 to 11) := (others => (others => '0'));
    
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
    
begin

    reset <= '0'; clk_enable <= '1';
    
    CLOCK_ANC : process
    begin
        clk <= '0';
        wait for t1/2;
        clk <= '1';
        wait for t1/2;
    end process;

    SINE_WAVE_150 : entity work.sine_generator(amplitude_15) --150Hz sine output, 1K sample period
    port map(clk => clk_sine_150, reset => reset, clk_enable => sine_en, Out1 => sine_out_150);
    SINE_WAVE_200 : entity work.sine_generator(amplitude_15) --150Hz sine output, 1K sample period
    port map(clk => clk_sine_200, reset => reset, clk_enable => sine_en, Out1 => sine_out_200);
    SINE_en <= '1';
    SINE_BUFFER : process(clk_anc) begin
        if rising_edge(clk_anc) then
            sine_out_150_ds <= sine_out_150;
            sine_out_200_ds <= sine_out_200;
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
    generic map(count => 834) port map(clk_in => clk, clk_out => clk_sine_150);
    CLK_GEN_50Khz : entity work.clk_div --15Khz drives 150Hz sine
    generic map(count => 600) port map(clk_in => clk, clk_out => clk_sine_200);


    LMS_UPDATE_12 : entity work. LMS_Filter_12_EConverted
    port map(
        clk => clk_anc,
        reset => reset,
        clk_enable => LMSU1_en,
        input => LMSU1_input,
        error => LMSU1_error,
        adapt => adapt,
        weights => Wanc
    );
        LMSU1_input <= sine_out_150_ds;
        LMSU1_error <= std_logic_vector(shift_right(signed(sine_out_200_ds),2));
        LMSU1_en <= '1';
        adapt <= '1';
    
    LMS_UPDATE_FSM : entity work.LMS_Update_FSM
    generic map(L => L, W => W)
    port map(
        clk_anc 	=> clk_anc,
        clk_dsp 	=> clk_dsp,
        clk_ila     => clk_ila,
        reset 		=> reset,
        en			=> LMSU2_en,
        input		=> LMSU2_input,
        error		=> LMSU2_error,
        adapt		=> adapt,
        --ram interface
        wt_addr		=> addra,
        wt_ram_en	=> ena,
        wt_wr_en	=> wea(0),
        wt_data_in	=> douta,
        wt_data_out	=> dina
    );
        LMSU2_input <= sine_out_150_ds;
        LMSU2_error <= std_logic_vector(shift_right(signed(sine_out_200_ds),2));
        LMSU2_en <= '1';
    
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
end Behavioral;