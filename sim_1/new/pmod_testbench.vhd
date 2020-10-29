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
    signal clk1, clk2, reset, clk_enable, ce_out : std_logic;
    
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

    constant clk_period1 : time := 44.289 ns;
    constant clk_period2 : time := 100us;
begin
    reset <= '0';
    clk_enable <= '1';
    
    SINE_WAVE : entity work.sine_generator
    port map(
        clk => clk2,
        reset => reset,
        clk_enable => clk_enable,
        ce_out => ce_out,
        Out1 => data_spkr
    );
    
    CLOCK1: process
    begin
        clk1 <= '0';
        wait for clk_period1/2;
        clk1 <= '1';
        wait for clk_period1/2;
    end process;
    
    CLOCK2: process
    begin
        clk2 <= '0';
        wait for clk_period2/2;
        clk2 <= '1';
        wait for clk_period2/2;
    end process;
        
--    UUT: entity work.pmod_i2s2
--    port map(
--        clk => clk1,
--        reset => reset,
--        data_mic => data_mic,
--        data_spkr => data_spkr,
--        tx_mclk => tx_mclk,
--        tx_lrck => tx_lrck,
--        tx_sclk => tx_sclk,
--        tx_data => tx_data,
--        rx_mclk => rx_mclk,
--        rx_lrck => rx_lrck,
--        rx_sclk => rx_sclk,
--        rx_data => rx_data
--    );
end Behavioral;
