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
    signal clk, clk_44Khz, reset, clk_enable, ce_out, adapt : std_logic := '0';
    signal input, desired: std_logic_vector(23 downto 0);
    signal weights, weights_24 : vector_of_std_logic_vector24(0 to 11) := (others => (others => '0'));
    constant clk_period : time := 10ns;
    signal sine_out, rand_out : std_logic_vector(23 downto 0);
    signal count_44Khz : natural range 0 to 2300;
    signal noisy_sine : std_logic_vector(23 downto 0);
begin

    TEST: process
    begin
        wait until rising_edge(clk);
        clk_enable <= '1'; adapt <= '1';
        input <= X"010111";
        desired <= X"000011";
        wait until rising_edge(clk);
        
        input <= X"001111";
        desired <= X"100011";
        wait until rising_edge(clk);
        
        input <= X"011101";
        desired <= X"101111";
        wait until rising_edge(clk);
        
        input <= X"011000";
        desired <= X"101111";
        wait until rising_edge(clk);
        
        input <= X"111111";
        desired <= X"110011";
    
    end process;
    
    reset <= '0'; clk_enable <= '1';
    
--    sine : entity work.sine_generator
--    port map(
--        clk => clk,
--        reset => reset,
--        clk_enable => clk_enable,
--        ce_out => ce_out,
--        Out1 => sine_out
--    );
    
--    random : entity work.PRBS
--    port map(
--        clk => clk,
--        rst => reset,
--        ce => clk_enable,
--        rand => rand_out
--    );
    
--    noisy_sine <= std_logic_vector( signed(sine_out) + signed(rand_out(7 downto 0)) );
    
    CLOCK: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;
    
--    FIR : entity work.FIR_Filter_Subsystem
--    port map(
    
--    );
    
    LMS_24: entity work.LMS_Filter_24_Subsystem
    port map(
        clk => clk,
        reset => reset,
        clk_enable => clk_enable,
        input => input,
        desired => desired,
        adapt => adapt,
        ce_out => ce_out,
        weights => weights_24
    );

end Behavioral;
