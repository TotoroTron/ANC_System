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
    signal clk, reset, enb, validIn, validOut : std_logic := '0';
    signal dataIn, dataOut : std_logic_vector(23 downto 0);
    signal Coeff : vector_of_std_logic_vector24(0 to 11) := (others => X"400000");
    constant clk_period : time := 10ns;

begin
    
    
    TEST: process
    begin
        wait until rising_edge(clk);
        validIn <= '1'; enb <= '1';
        dataIn <= std_logic_vector(to_signed(3,24));
        wait until rising_edge(clk);
        
        dataIn <= std_logic_vector(to_signed(1,24));
        wait until rising_edge(clk);
        
        dataIn <= std_logic_vector(to_signed(4,24));
        wait until rising_edge(clk);
        
        dataIn <= std_logic_vector(to_signed(2,24));
        wait until rising_edge(clk);
        
        dataIn <= std_logic_vector(to_signed(1,24));
    
    end process;
    
    CLOCK: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;
    
    UUT: entity work.Discrete_FIR_Filter_HDL_Optimized
    port map(
        clk => clk,
        reset => reset,
        enb => enb,
        dataIn => dataIn,
        validIn => validIn,
        Coeff => Coeff,
        dataOut => dataOut,
        validOut => validOut
    );

end Behavioral;
