library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
USE work.top_level_pkg.ALL;

Library xpm;
use xpm.vcomponents.all;

entity top_level_2 is
	port(
        clk : in std_logic; --125 Mhz
        reset : in std_logic; --reset
        enable : in std_logic; --ANC adapt enable
		
		--JA line out
		ja_tx_mclk : out std_logic;
		ja_tx_lrck : out std_logic;
		ja_tx_sclk : out std_logic;
		ja_tx_data : out std_logic;
		
		--JA line in
		ja_rx_mclk : out std_logic;
		ja_rx_lrck : out std_logic;
		ja_rx_sclk : out std_logic;
		ja_rx_data : in std_logic;
		
	    --JB line out
        jb_tx_mclk : out std_logic;
        jb_tx_lrck : out std_logic;
        jb_tx_sclk : out std_logic;
        jb_tx_data : out std_logic;
        
        --JB line in
        jb_rx_mclk : out std_logic;
        jb_rx_lrck : out std_logic;
        jb_rx_sclk : out std_logic;
        jb_rx_data : in std_logic
	);
end entity top_level_2;

architecture rtl of top_level_2 is
    signal noise, antiNoise, noiseAmp, antiNoiseAmp : std_logic_vector(31 downto 0);
    signal refMic, errMic, refMicAmp, errMicAmp : std_logic_vector(31 downto 0);
    signal tx_valid, tx_ready, tx_last, ja_tx_ready : std_logic;
    signal rx_valid, rx_ready, rx_last, ja_rx_valid, ja_rx_last: std_logic;
    signal clk_5Mhz, clk_44Khz, clk_22Khz, clk_41Khz, clk_ila, clk_anc, clk_dsp, resetn : std_logic := '0';
    signal sine_en : std_logic;
    signal count : unsigned(8 downto 0) := (others => '0');
    component axis_i2s2 is
    port(
        axis_clk : in std_logic;
        axis_resetn : in std_logic;
        count : in unsigned(8 downto 0);
        tx_axis_s_data : in std_logic_vector(31 downto 0);
        tx_axis_s_valid : in std_logic;
        tx_axis_s_ready : out std_logic;
        tx_axis_s_last : in std_logic;
        
        rx_axis_m_data : out std_logic_vector(31 downto 0);
        rx_axis_m_valid : out std_logic;
        rx_axis_m_ready : in std_logic;
        rx_axis_m_last : out std_logic;
        
        tx_mclk : out std_logic;
        tx_lrck : out std_logic;
        tx_sclk : out std_logic;
        tx_sdout: out std_logic;

        rx_mclk : out std_logic; 
        rx_lrck : out std_logic;
        rx_sclk : out std_logic;
        rx_sdin : in std_logic
    );
    end component;
    CONSTANT L : INTEGER := 12;
    CONSTANT W : INTEGER := 1;
    CONSTANT R : INTEGER := L/W;

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
    signal sine_out : std_logic_vector(23 downto 0);
    signal EXTRA_en : std_logic;
    signal EXTRA_FilterOut : std_logic_vector(23 downto 0);
    signal gnd : std_logic := '0';
begin
    resetn <= NOT reset;
    errMicAmp <= std_logic_vector( shift_left( signed(errMic), 2)); --amplify 4x
    refMicAmp <= std_logic_vector( shift_left( signed(refMic), 2)); --amplify 4x
    noiseAmp <= noise;
    antiNoiseAmp <= antiNoise;
    JA_PMOD_I2S2 : axis_i2s2
    port map(
        axis_clk => clk_5Mhz,           --input
        axis_resetn => resetn,          --input
        count => count,
        
        tx_axis_s_data => antiNoiseAmp, --input
        tx_axis_s_valid => tx_valid,    --input
        tx_axis_s_ready => ja_tx_ready, --output
        tx_axis_s_last => tx_last,      --input
        
        rx_axis_m_data => errMic,       --output
        rx_axis_m_valid => ja_rx_valid, --output
        rx_axis_m_ready => rx_ready,    --input
        rx_axis_m_last => ja_rx_last,   --output
        
        tx_mclk => ja_tx_mclk,          --output
        tx_lrck => ja_tx_lrck,          --output
        tx_sclk => ja_tx_sclk,          --output
        tx_sdout => ja_tx_data,         --output         
        
        rx_mclk => ja_rx_mclk,          --output
        rx_lrck => ja_rx_lrck,          --output
        rx_sclk => ja_rx_sclk,          --output
        rx_sdin => ja_rx_data           --input
    );
        
    JB_PMOD_I2S2 : axis_i2s2
    port map(
        axis_clk => clk_5Mhz,           --input
        axis_resetn => resetn,          --input
        count => count,
        
        tx_axis_s_data => noiseAmp,     --input
        tx_axis_s_valid => tx_valid,    --input
        tx_axis_s_ready => tx_ready,    --output
        tx_axis_s_last => tx_last,      --input
        
        rx_axis_m_data => refMic,       --output
        rx_axis_m_valid => rx_valid,    --output
        rx_axis_m_ready => rx_ready,    --input
        rx_axis_m_last => rx_last,      --output
        
        tx_mclk => jb_tx_mclk,          --output
        tx_lrck => jb_tx_lrck,          --output
        tx_sclk => jb_tx_sclk,          --output
        tx_sdout => jb_tx_data,         --output
        
        rx_mclk => jb_rx_mclk,          --output
        rx_lrck => jb_rx_lrck,          --output
        rx_sclk => jb_rx_sclk,          --output
        rx_sdin => jb_rx_data           --input
    );
    
    I2S_CONTROLLER : entity work.i2s_controller
    port map(
        clk => clk_5Mhz,
        s_axis_valid => rx_valid,
        s_axis_ready => rx_ready,
        s_axis_last => rx_last,
        m_axis_valid => tx_valid,
        m_axis_ready => tx_ready,
        m_axis_last => tx_last        
    );
    
    SINE_WAVE_150 : entity work.sine_generator(amplitude_25) --150Hz sine output, 1K sample period
    port map(clk => clk_41Khz, reset => reset, clk_enable => SINE_en, Out1 => sine_out);
    SINE_en <= '1';

    SINE_BUFFER : process(clk_anc) begin
        if rising_edge(clk_anc) then
            noise(23 downto 0) <= sine_out;
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
    generic map(count => 834) port map(clk_in => clk, clk_out => clk_41Khz);
    CLK_GEN_ILA : entity work.clk_div --375Khz drives ILA debugger. clock must be >2.5x JTAG clk
    generic map(count => 334) port map(clk_in => clk, clk_out => clk_ila);
    
--    CLK_DIV_ANC : entity work.clk_div(short_pulse)
--    generic map( count => 1024 ) port map( clk_in => clk_5Mhz, clk_out => clk_anc);
    
    EXTRA_FILTER : entity work.Discrete_FIR_Filter_FSM
    generic map(L => L, W => W)
    port map(
        clk_anc 	=> clk_anc,
        clk_dsp 	=> clk_dsp,
        clk_ila     => clk_ila,
        reset 		=> reset,
        en			=> enable,
        input		=> refMic(23 downto 0),
        output		=> EXTRA_FilterOut,
        --ram interface
        addr		=> addrb,
        ram_en		=> enb,
        wr_en		=> web(0),
        data_in		=> doutb,
        data_valid	=> lms_data_valid
    );
        lms_data_valid <= NOT clk_anc;

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
    end generate;
end architecture rtl;