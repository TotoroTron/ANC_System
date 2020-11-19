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
    
    signal LMS_Coeff : vector_of_std_logic_vector24(0 to 23) := (others => (others => '0'));
    signal FIR_Coeff : vector_of_std_logic_vector24(0 to 23) := (others => (others => '0'));
    
    signal sine_out, fir_out : std_logic_vector(23 downto 0);
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
    
    SINE_GEN : entity work.sine_generator(amplitude_49)
    port map(
        clk => clk,
        reset => reset,
        clk_enable => clk_enable,
        Out1 => sine_out
    );
    
    FIR_FILTER : entity work.Discrete_FIR_Filter_24
    port map(
        clk => clk,
        reset => reset,
        enb => clk_enable,
        Discrete_FIR_Filter_In => sine_out,
        Discrete_FIR_Filter_Coeff => FIR_Coeff,
        Discrete_FIR_Filter_Out => fir_out
    );
        FIR_Coeff(10) <= X"400000";
        FIR_Coeff(11) <= X"400000";
--        FIR_Coeff(0) <= X"400000"; -- 0.25
--        FIR_Coeff(1) <= X"C00000"; -- -0.25
--        FIR_Coeff(2) <= X"200000"; -- 0.125
--        FIR_Coeff(3) <= X"E00000"; -- -0.125
        
    LMS_FILTER : entity work.LMS_Filter_24
    port map(
        clk => clk,
        reset => reset,
        clk_enable => clk_enable,
        input => fir_out,
        desired => sine_out,
        adapt => adapt,
        weights => LMS_Coeff
    );
        adapt <= '1';

end Behavioral;
