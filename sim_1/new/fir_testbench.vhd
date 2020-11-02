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

entity fir_testbench is
--  Port ( );
end fir_testbench;

architecture Behavioral of fir_testbench is
    signal clk, reset, enb, ce_out, clk_enable : std_logic := '0';
    signal fir_in, fir_out, sine_out: std_logic_vector(23 downto 0);
    signal Coeff : vector_of_std_logic_vector24(0 to 11) := (others => (others => '0'));
    constant clk_period : time := 10ns;
    signal dummy : std_logic_vector(23 downto 0):= X"200000";
    signal dummy_out : std_logic_vector(23 downto 0);
begin
    dummy_out <= std_logic_vector(-signed(dummy));
    STIMULUS : process
    begin
        wait until rising_edge(clk);
        enb <= '1'; clk_enable <= '1';
        for i in 0 to 500 loop
        wait until rising_edge(clk);
        end loop;

        wait;
    end process;
    
        Coeff(0) <= X"400000"; --0.25
        Coeff(1) <= X"C00000"; ---0.25
        Coeff(2) <= X"200000"; --0.125
        Coeff(3) <= X"E00000"; ---0.125
    SINE : entity work.sine_generator
    port map(
        clk => clk,
        reset => reset,
        clk_enable => clk_enable,
        ce_out => ce_out,
        Out1 => sine_out
    );

    CLOCK: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;
    
    UUT: entity work.Discrete_FIR_Filter_24
    port map(
        clk => clk,
        reset => reset,
        enb => enb,
        Discrete_FIR_Filter_in => fir_in,
        Discrete_FIR_Filter_coeff => Coeff,
        Discrete_FIR_Filter_out => fir_out
    );
    fir_in <= sine_out;

end Behavioral;
