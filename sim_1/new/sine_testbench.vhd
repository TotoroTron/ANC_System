----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/20/2020 06:03:26 PM
-- Design Name: 
-- Module Name: sine_testbench - Behavioral
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

entity sine_testbench is
--  Port ( );
end sine_testbench;

architecture Behavioral of sine_testbench is
    signal clk, reset, clk_enable, ce_out : std_logic;
    signal sine_out : std_logic_vector(23 downto 0);
    constant clk_period : time := 10ns;
begin
    TEST_PROC : process
    begin
        reset <= '0';
        clk_enable <= '1';
        wait;
    end process;
    
    CLOCK: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;
    
    UUT : entity work.sine_generator
    port map(
        clk => clk,
        reset => reset,
        clk_enable => clk_enable,
        Out1 => sine_out
    );

end Behavioral;
