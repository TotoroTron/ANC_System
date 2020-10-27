
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.top_level_pkg.ALL;


entity lmsUpdate_testbench is
--  Port ( );
end lmsUpdate_testbench;
--
architecture Behavioral of lmsUpdate_testbench is
    signal clk, reset, clk_enable, adapt, ce_out, enb: std_logic := '0';
    signal input, error : std_logic_vector(23 downto 0) := (others => '0');
    signal weights : vector_of_std_logic_vector24(0 to 11) := (others => (others => '0'));
    constant clk_period : time := 10ns;
begin
    TEST : process
    begin
        input <= std_logic_vector(to_signed(300000,24));
        error <= std_logic_vector(to_signed(-20000,24));
        wait until rising_edge(clk);
        
        input <= std_logic_vector(to_signed(100000,24));
        error <= std_logic_vector(to_signed(10000,24));
        wait until rising_edge(clk);
        clk_enable <= '1';
        input <= std_logic_vector(to_signed(-420000,24));
        error <= std_logic_vector(to_signed(-15000,24));
        wait until rising_edge(clk);
        
        input <= std_logic_vector(to_signed(80000,24));
        error <= std_logic_vector(to_signed(20000,24));
        wait until rising_edge(clk);
        
        input <= std_logic_vector(to_signed(-250000,24));
        error <= std_logic_vector(to_signed(3000,24));
        wait until rising_edge(clk);
    end process;
    reset <= '0'; enb <= '1'; adapt <= '1';
    UUT : entity work.LMSUPDATE
    port map(
        clk => clk,
        reset => reset,
        enb => enb,
        X => input,
        E => error,
        adapt => adapt,
        W => weights
    );
    CLOCK: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;    
end Behavioral;
