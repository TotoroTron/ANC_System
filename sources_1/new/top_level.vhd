library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
USE work.top_level_pkg.ALL;
--
entity top_level is
	port(
        clk : in std_logic; --125 Mhz
        btn0 : in std_logic; --reset
        sw0 : in std_logic; --ANC adapt enable
		
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
end entity top_level;

architecture rtl of top_level is
    signal reset : std_logic := '0';
    signal noise, antiNoise, noiseSpkr, antiNoiseSpkr, refMic, errMic, refMicAmp, errMicAmp: std_logic_vector(31 downto 0);
    signal tx_valid, tx_ready, tx_last, ja_tx_ready : std_logic;
    signal rx_valid, rx_ready, rx_last, ja_rx_valid, ja_rx_last: std_logic;
    signal clk_5Mhz, clk_44Khz, clk_22Khz, clk_41Khz, clk_ila, resetn : std_logic := '0';
begin
    
    resetn <= NOT btn0;
    noiseSpkr <= noise;
    antiNoiseSpkr <= antiNoise;
    errMicAmp <= std_logic_vector( shift_left( signed(errMic), 5)); --amplify 32x
    refMicAmp <= std_logic_vector( shift_left( signed(refMic), 5)); --amplify 32x
    
--    errMicAmp <= errMic;
--    refMicAmp <= refMic;
    
    JA_PMOD_I2S2 : entity work.axis_i2s2
    port map(
        axis_clk => clk_5Mhz,          --input
        axis_resetn => resetn,          --input
        
        tx_axis_s_data => antiNoiseSpkr,--input
        tx_axis_s_valid => tx_valid,    --input
        tx_axis_s_ready => ja_tx_ready, --output
        tx_axis_s_last => tx_last,      --input
        
        rx_axis_m_data => errMic,    --output
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
        
    JB_PMOD_I2S2 : entity work.axis_i2s2
    port map(
        axis_clk => clk_5Mhz,          --input
        axis_resetn => resetn,          --input
        
        tx_axis_s_data => noiseSpkr,    --input
        tx_axis_s_valid => tx_valid,    --input
        tx_axis_s_ready => tx_ready,    --output
        tx_axis_s_last => tx_last,      --input
        
        rx_axis_m_data => refMic,    --output
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
    
    ANC_SYSTEM : entity work.ANC_System
    port map(
        clk => clk,
        btn0 => btn0, --reset
        sw0 => sw0, --ANC adapt enable
        refMic_in => refMicAmp(23 downto 0),
        errMic_in => errMicAmp(23 downto 0),
        antiNoise_out => antiNoise(23 downto 0),
        noise_out => noise(23 downto 0)
    );
        
    PMOD_CLK : clk_wiz_0
    port map(clk_in1 => clk, clk_out1 => clk_5Mhz);
    
end architecture rtl;