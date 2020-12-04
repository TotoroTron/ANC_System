----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/03/2020 09:19:33 PM
-- Design Name: 
-- Module Name: Discrete_FIR_Filter - Behavioral
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


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.top_level_pkg.ALL;

ENTITY Discrete_FIR_Filter IS
  PORT( clk                               :   IN    std_logic;
        reset                             :   IN    std_logic;
        enb                               :   IN    std_logic;
        input                             :   IN    std_logic_vector(23 DOWNTO 0);  -- sfix24_En24
        coeff                             :   IN    vector_of_std_logic_vector24(0 TO 11);  -- sfix24_En24 [12]
        output                            :   OUT   std_logic_vector(23 DOWNTO 0)  -- sfix24_En24
        );
END Discrete_FIR_Filter;

architecture Behavioral of Discrete_FIR_Filter is
    signal input_signed : signed(23 downto 0) := (others => '0');
    signal coeff_signed : signed(23 downto 0) := (others => '0');
begin
    
    
    
    
    

end Behavioral;
