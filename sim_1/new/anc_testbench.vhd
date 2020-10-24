----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/24/2020 11:04:05 AM
-- Design Name: 
-- Module Name: anc_testbench - Behavioral
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
USE work.top_level_pkg.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity anc_testbench is
--  Port ( );
end anc_testbench;

architecture Behavioral of anc_testbench is
    signal clk, btn0, sw0 : std_logic := '0';
    signal antiNoise, noise : std_logic_vector(23 downto 0);
    constant clk_period : time := 10 ns;
    signal ce_out, reset, clk_enable : std_logic;
    signal sine_out, rand_out : std_logic_vector(23 downto 0);
begin
    TEST_PROC : process
    begin
        reset <= '0';
        clk_enable <= '1';
        for i in 0 to 1400 loop
        wait until rising_edge(clk);
        end loop;
        sw0 <= '1';
        wait;
    end process;
    
    sine : entity work.sine_generator
    port map(
        clk => clk,
        reset => reset,
        clk_enable => clk_enable,
        ce_out => ce_out,
        Out1 => sine_out
    );
    
    random : entity work.PRBS
    port map(
        clk => clk,
        rst => reset,
        ce => clk_enable,
        rand => rand_out
        
    );
    
    CLOCK: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;
    
    UUT : entity work.ANC_System
    port map (
        clk => clk,
        btn0 => btn0,
        sw0 => sw0,
        refMic => sine_out,
        errMic => rand_out,
        antiNoise => antiNoise,
        noise => noise
    );
    

end Behavioral;
