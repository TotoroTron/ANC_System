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
    signal clk, clk_44Khz, reset, clk_enable, ce_out, LMS_ceout, adapt : std_logic := '0';
    constant clk_period : time := 10ns;
    
    signal LMS_input, LMS_desired: std_logic_vector(23 downto 0);
    signal LMS_Coeff : vector_of_std_logic_vector24(0 to 11) := (others => (others => '0'));
    
    signal sine_out, stair_sequence, noisy_sine  : std_logic_vector(23 downto 0);
    signal tmp : std_logic_vector(23 downto 0) := (others => '0');
begin

    CLOCK: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;
    
    reset <= '0'; clk_enable <= '1';
    
    sine : entity work.sine_generator
    port map(
        clk => clk,
        reset => reset,
        clk_enable => clk_enable,
        Out1 => sine_out
    );
    
    REPEATING_SEQUENCE : process
    begin
        stair_sequence <= "000100011110101110000101"; -- 0.07
        wait until rising_edge(clk);
        
        tmp <= "000100011110101110000101";
        stair_sequence <= std_logic_vector(-signed(tmp)); -- -0.05
        wait until rising_edge(clk);
        
        stair_sequence <= "000111000010100011110101"; -- 0.11
        wait until rising_edge(clk);
        
        stair_sequence <= "001001100110011001100110"; --0.15
        wait until rising_edge(clk);
        
        tmp <= "000000101000111101011100";
        stair_sequence <= std_logic_vector(-signed(tmp)); -- -0.01
        wait until rising_edge(clk);
        
        tmp <= "000101110000101000111101";
        stair_sequence <= std_logic_vector(-signed(tmp)); -- -0.09
        wait until rising_edge(clk);
        
        tmp <= "001000010100011110101110";
        stair_sequence <= std_logic_vector(-signed(tmp)); -- -0.13
        wait until rising_edge(clk);
        
        stair_sequence <= "000010100011110101110000";
        wait until rising_edge(clk);
    end process;
    
    noisy_sine <= std_logic_vector( signed(sine_out) + signed(stair_sequence) );
    
    LMS : entity work.LMS_Filter_24
    port map(
        clk => clk,
        reset => reset,
        clk_enable => clk_enable,
        input => LMS_input,
        desired => LMS_desired,
        adapt => adapt,
        weights => LMS_Coeff
    );
        LMS_input <= noisy_sine;
        LMS_desired <= sine_out;
        adapt <= '1';

end Behavioral;
