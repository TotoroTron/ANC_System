library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
USE work.anc_package.ALL;

entity top_testbench is
--  Port ( );--
end top_testbench;

architecture Behavioral of top_testbench is
    signal clk   : std_logic; --100 Mhz
    signal reset         : std_logic;
    signal enable          : std_logic;
    signal ja_tx_mclk   :  std_logic;
    signal ja_tx_lrck   :  std_logic;
    signal ja_tx_sclk   :  std_logic;
    signal ja_tx_data   :  std_logic;
    signal ja_rx_mclk   :  std_logic;
    signal ja_rx_lrck   :  std_logic;
    signal ja_rx_sclk   :  std_logic;
    signal ja_rx_data   : std_logic;
    signal jb_tx_mclk   :  std_logic;
    signal jb_tx_lrck   :  std_logic;
    signal jb_tx_sclk   :  std_logic;
    signal jb_tx_data   :  std_logic;
    signal jb_rx_mclk   :  std_logic;
    signal jb_rx_lrck   :  std_logic;
    signal jb_rx_sclk   :  std_logic;
    signal jb_rx_data   : std_logic;
    constant clk_period : time := 10ns;
begin

    UUT: entity work.top_level
    port map(
        clk         => clk, 
        reset       => reset, 
        enable      => enable,
         
		ja_tx_mclk  => ja_tx_mclk,    
		ja_tx_lrck  => ja_tx_lrck,    
		ja_tx_sclk  => ja_tx_sclk,    
		ja_tx_data  => ja_tx_data,    
		ja_rx_mclk  => ja_rx_mclk,    
		ja_rx_lrck  => ja_rx_lrck,    
		ja_rx_sclk  => ja_rx_sclk,    
		ja_rx_data  => ja_rx_data, 
		    
        jb_tx_mclk  => jb_tx_mclk,
        jb_tx_lrck  => jb_tx_lrck,
        jb_tx_sclk  => jb_tx_sclk,
        jb_tx_data  => jb_tx_data,
        jb_rx_mclk  => jb_rx_mclk,
        jb_rx_lrck  => jb_rx_lrck,
        jb_rx_sclk  => jb_rx_sclk,
        jb_rx_data  => jb_rx_data 
    );
    
    ja_rx_data <= '1';
    jb_rx_data <= '1';
    reset <= '0';
    enable <= '1';
    
    CLOCK: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;
    
end Behavioral;
