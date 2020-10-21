library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
USE work.top_level_pkg.ALL;

entity top_level is
	port(
        clk : in std_logic;
        btn0, btn1 : in std_logic;
        sw0, sw1 : in std_logic;
		
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
		
        --JB line in
        jb_rx_mclk : out std_logic;
        jb_rx_lrck : out std_logic;
        jb_rx_sclk : out std_logic;
        jb_rx_data : in std_logic
	);
end entity top_level;

architecture rtl of top_level is
    signal reset : std_logic;
    signal antiNoise, refMic, errMic : std_logic_vector(23 downto 0);
    signal vterminator : std_logic_vector(23 downto 0);
    signal bterminator : std_logic;
begin

    JA_PMOD : entity work.pmod_i2s2
    port map(
        clk => clk,
        reset => reset,
        data_mic => refMic,
        data_spkr => antiNoise,
        tx_mclk => ja_tx_mclk,
        tx_lrck => ja_tx_lrck,
        tx_sclk => ja_tx_sclk,
        tx_data => ja_tx_data,
        rx_mclk => ja_rx_mclk,
        rx_lrck => ja_rx_lrck,
        rx_sclk => ja_rx_sclk,
        rx_data => ja_rx_data
    );
    
    JB_PMOD : entity work.pmod_i2s2
    port map(
        clk => clk,
        reset => reset,
        data_mic => errMic,
        data_spkr => vterminator,
        tx_mclk => bterminator,
        tx_lrck => bterminator,
        tx_sclk => bterminator,
        tx_data => bterminator,
        rx_mclk => jb_rx_mclk,
        rx_lrck => jb_rx_lrck,
        rx_sclk => jb_rx_sclk,
        rx_data => jb_rx_data
    );
    
    ANC_SYSTEM : entity work.ANC_System
    port map(
        clk => clk,
        btn0 => btn0,
        btn1 => btn1,
        sw0 => sw0,
        sw1 => sw1,
        refMic => refMic,
        errMic => errMic,
        antiNoise => antiNoise
    );
    
end architecture rtl;