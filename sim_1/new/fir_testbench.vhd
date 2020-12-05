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
    signal clk_anc, clk_dsp, reset, enb, ce_out, clk_enable : std_logic := '0';
    signal fir1_in, fir1_out, fir2_in, fir2_out, sine_out: std_logic_vector(23 downto 0);
    signal Coeff : vector_of_std_logic_vector24(0 to 23) := (others => (others => '0'));
    constant t1 : time := 500ns;
    constant t2 : time := 10ns;
begin
    STIMULUS : process
    begin
        enb <= '1'; clk_enable <= '1';
--        for i in 0 to 500 loop
--        wait until rising_edge(clk_anc);
--        end loop;

        wait;
    end process;
    
        Coeff(0) <= X"400000"; -- 0.25
        Coeff(1) <= X"C00000"; -- -0.25
        Coeff(2) <= X"200000"; -- 0.125
        Coeff(3) <= X"E00000"; -- -0.125
    SINE : entity work.sine_generator(amplitude_49)
    port map(
        clk => clk_anc,
        reset => reset,
        clk_enable => clk_enable,
        Out1 => sine_out
    );

    CLOCK_ANC: process
    begin
        clk_anc <= '0';
        wait for t1/2;
        clk_anc <= '1';
        wait for t1/2;
    end process;
    
    CLOCK_DSP: process
    begin
        clk_dsp <= '0';
        wait for t2/2;
        clk_dsp <= '1';
        wait for t2/2;
    end process;
    
    PARALLEL: entity work.Discrete_FIR_Filter_24
    port map(
        clk => clk_anc,
        reset => reset,
        enb => enb,
        Discrete_FIR_Filter_in => fir1_in,
        Discrete_FIR_Filter_coeff => Coeff,
        Discrete_FIR_Filter_out => fir1_out
    );
    fir1_in <= sine_out;
    
    PIPELINED: entity work.Discrete_FIR_Filter
    generic map(L => 24)
    port map(
        clk_anc => clk_anc,
        clk_dsp => clk_dsp,
        reset => reset,
        enb => enb,
        input => fir2_in,
        coeff => coeff,
        output => fir2_out
    );
    fir2_in <= sine_out;
end Behavioral;
