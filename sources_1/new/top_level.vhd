library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
USE work.top_level_pkg.ALL;

entity top_level is
	port(

        clk : in std_logic;
        btn0, btn1, btn2, btn3  : in std_logic;
        sw0, sw1 : in std_logic;
		
		--line out
		tx_mclk : out std_logic;
		tx_lrck : out std_logic;
		tx_sclk : out std_logic;
		tx_data : out std_logic;
		
		--line in
		rx_mclk : out std_logic;
		rx_lrck : out std_logic;
		rx_sclk : out std_logic;
		rx_data : in std_logic
	);
end entity top_level;