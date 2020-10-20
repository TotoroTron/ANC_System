----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/19/2020 11:23:11 PM
-- Design Name: 
-- Module Name: pmod_testbench - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pmod_testbench is
--  Port ( );
end pmod_testbench;

architecture Behavioral of pmod_testbench is
    signal clk, reset : std_logic;
    
    signal data_mic : std_logic_vector(23 downto 0);
    signal data_spkr : std_logic_vector(23 downto 0);
    
    signal tx_mclk : std_logic;
    signal tx_lrck : std_logic;
    signal tx_sclk : std_logic;
    signal tx_data : std_logic;

    signal rx_mclk : std_logic;
    signal rx_lrck : std_logic;
    signal rx_sclk : std_logic;
    signal rx_data : std_logic;

    constant clk_period : time := 44.289 ns;
begin
    
    TEST_PROC : process
    begin
        reset <= '0';
        data_spkr <= X"123456";
        wait;
    end process;
    
    CLOCK: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;
    
    UUT: entity work.pmod_i2s2
    port map(
        clk => clk,
        reset => reset,
        data_mic => data_mic,
        data_spkr => data_spkr,
        tx_mclk => tx_mclk,
        tx_lrck => tx_lrck,
        tx_sclk => tx_sclk,
        tx_data => tx_data,
        rx_mclk => rx_mclk,
        rx_lrck => rx_lrck,
        rx_sclk => rx_sclk,
        rx_data => rx_data
    );
end Behavioral;
