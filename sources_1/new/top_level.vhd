library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
USE work.top_level_pkg.ALL;
--
entity top_level is
	port(
        clk_100Mhz : in std_logic; --100 Mhz
        btn0 : in std_logic;
        sw0 : in std_logic;
		
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
    component clk_wiz_0 port(clk_in1 : in std_logic; clk_out1 : out std_logic); end component;
    signal reset : std_logic := '0';
    signal noise, antiNoise, noiseSpkr, antiNoiseSpkr, refMic, errMic, refMicAmp, errMicAmp: std_logic_vector(31 downto 0) := (others => '0');
    signal tx_valid, tx_ready, tx_last, ja_tx_ready : std_logic;
    signal rx_valid, rx_ready, rx_last, ja_rx_valid, ja_rx_last: std_logic;
    signal clk_22Mhz, clk_44Khz, clk_22Khz, clk_41Khz, resetn : std_logic := '0';
    signal count_44Khz, count_22Khz, count_41Khz : natural range 0 to 65535;
    signal antiNoiseSpkrBuffer : vector_of_signed24(0 to 81) := (others => (others => '0'));
    COMPONENT ILA_0
        PORT(
            CLK : IN STD_LOGIC;
            PROBE0 : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
            PROBE1 : IN STD_LOGIC_VECTOR(23 DOWNTO 0)
        );
    END COMPONENT;
begin
    resetn <= '1';
    --errMicAmp <= std_logic_vector(shift_left(signed(errMic),4));
    errMicAmp <= errMic;
    --refMicAmp <= std_logic_vector(shift_left(signed(refMic),4));
    refMicAmp <= refMic;
    
--    antiNoiseSpkr(23 downto 0) <= std_logic_vector(antiNoiseSpkrBuffer(81));
    antiNoiseSpkr <= antiNoise;
--    ANTINOISE_BUFFER : process(clk_44khz)
--    begin
--        if rising_edge(clk_44khz) then
--            antiNoiseSpkrBuffer(0) <= signed(antiNoise(23 downto 0));
--            antiNoiseSpkrBuffer(1 to 81) <= antiNoiseSpkrBuffer(0 to 80);
--        end if;
--    end process;
    
    DEBUGGER : ila_0
    PORT MAP(
        clk => clk_44Khz,
        probe0 => antiNoiseSpkr(23 downto 0),
        probe1 => noiseSpkr(23 downto 0)
    );
    
    JA_PMOD_I2S2 : entity work.axis_i2s2
    port map(
        axis_clk => clk_22Mhz,              --input
        axis_resetn => resetn,              --input
        
        tx_axis_s_data => antiNoiseSpkr,    --input
        tx_axis_s_valid => tx_valid,        --input
        tx_axis_s_ready => ja_tx_ready,        --output
        tx_axis_s_last => tx_last,          --input
        
        rx_axis_m_data => errMicAmp,           --output
        rx_axis_m_valid => ja_rx_valid,        --output
        rx_axis_m_ready => rx_ready,        --input 
        rx_axis_m_last => ja_rx_last,          --output
        
        tx_mclk => ja_tx_mclk,              --output   
        tx_lrck => ja_tx_lrck,              --output   
        tx_sclk => ja_tx_sclk,              --output   
        tx_sdout => ja_tx_data,             --output   
        
        rx_mclk => ja_rx_mclk,              --output   
        rx_lrck => ja_rx_lrck,              --output   
        rx_sclk => ja_rx_sclk,              --output   
        rx_sdin => ja_rx_data               --input    
    );
        
    
    JB_PMOD_I2S2 : entity work.axis_i2s2
    port map(
        axis_clk => clk_22Mhz,              --input
        axis_resetn => resetn,              --input
        
        tx_axis_s_data => noiseSpkr,        --input
        tx_axis_s_valid => tx_valid,        --input
        tx_axis_s_ready => tx_ready,        --output
        tx_axis_s_last => tx_last,          --input
        
        rx_axis_m_data => refMicAmp,           --output
        rx_axis_m_valid => rx_valid,        --output
        rx_axis_m_ready => rx_ready,        --input
        rx_axis_m_last => rx_last,          --output
        
        tx_mclk => jb_tx_mclk,              --output   
        tx_lrck => jb_tx_lrck,              --output   
        tx_sclk => jb_tx_sclk,              --output   
        tx_sdout => jb_tx_data,             --output   
        
        rx_mclk => jb_rx_mclk,              --output   
        rx_lrck => jb_rx_lrck,              --output   
        rx_sclk => jb_rx_sclk,              --output   
        rx_sdin => jb_rx_data               --input    
    );
    
    I2S_CONTROLLER : entity work.i2s_controller
    port map(
        clk => clk_22Mhz,
        s_axis_valid => rx_valid,
        s_axis_ready => rx_ready,
        s_axis_last => rx_last,
        m_axis_valid => tx_valid,
        m_axis_ready => tx_ready,
        m_axis_last => tx_last        
    );
    
    ANC_SYSTEM : entity work.ANC_System
    port map(
        clk_44Khz => clk_44Khz,
        clk_22Khz => clk_22Khz,
        clk_41Khz => clk_41Khz,
        btn0 => btn0,
        sw0 => sw0,
        refMic => refMic(23 downto 0),
        errMic => errMic(23 downto 0),
        antiNoise => antiNoise(23 downto 0),
        noise => noise(23 downto 0)
    );
    noiseSpkr <= noise;
    
    PMOD_CLK : clk_wiz_0
    port map(
        clk_in1 => clk_100Mhz,
        clk_out1 => clk_22Mhz
    );
    
    CLK_GEN_44Khz : process(clk_100Mhz) --44.1 Khz
    begin
        if rising_edge(clk_100Mhz) then
        if count_44Khz = 1417 then
            clk_44Khz <= NOT clk_44Khz;
            count_44Khz <= 0;
        else
            count_44Khz <= count_44Khz + 1;
        end if;
        end if;
    end process;
    
    CLK_GEN_22Khz : process(clk_100Mhz) --22.5Khz
    begin
        if rising_edge(clk_100Mhz) then
        if count_22Khz = 2778 then
            clk_22Khz <= NOT clk_22Khz;
            count_22Khz <= 0;
        else
            count_22Khz <= count_22Khz + 1;
        end if;
        end if;
    end process;
    
    CLK_GEN_41Khz : process(clk_100Mhz) --15Khz
    begin
        if rising_edge(clk_100Mhz) then
        if count_41Khz = 4167 then
            clk_41Khz <= NOT clk_41Khz;
            count_41Khz <= 0;
        else
            count_41Khz <= count_41Khz + 1;
        end if;
        end if;
    end process;
end architecture rtl;