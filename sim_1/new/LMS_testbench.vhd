----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/18/2020 12:40:22 PM
-- Design Name: 
-- Module Name: fir_testbench - Behavioral
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
USE IEEE.numeric_std.ALL;
USE work.top_level_pkg.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity LMS_testbench is
--  Port ( );
end LMS_testbench;

architecture Behavioral of LMS_testbench is
    signal clk, reset, clk_enable, ce_out : std_logic := '0';
    signal input, desired: std_logic_vector(23 downto 0);
    signal weights : vector_of_std_logic_vector24(0 to 11) := (others => (others => '0'));
    constant clk_period : time := 10ns;

begin

    TEST: process
    begin
        wait until rising_edge(clk);
        clk_enable <= '1';
        input <= std_logic_vector(to_signed(3,24));
        desired <= std_logic_vector(to_signed(4,24));
        wait until rising_edge(clk);
        
        input <= std_logic_vector(to_signed(1,24));
        desired <= std_logic_vector(to_signed(2,24));
        wait until rising_edge(clk);
        
        input <= std_logic_vector(to_signed(4,24));
        desired <= std_logic_vector(to_signed(-1,24));
        wait until rising_edge(clk);
        
        input <= std_logic_vector(to_signed(2,24));
        desired <= std_logic_vector(to_signed(-2,24));
        wait until rising_edge(clk);
        
        input <= std_logic_vector(to_signed(1,24));
        desired <= std_logic_vector(to_signed(1,24));
    
    end process;
    
    CLOCK: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;
    
    UUT: entity work.LMSFilter
    port map(
        clk => clk,
        reset => reset,
        clk_enable => clk_enable,
        In1 => input,
        In2 => desired,
        ce_out => ce_out,
        Out3 => weights
    );

end Behavioral;
