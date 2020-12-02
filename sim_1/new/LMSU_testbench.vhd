
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.top_level_pkg.ALL;


entity LMSU_testbench is
--  Port ( );
end LMSU_testbench;
--
architecture Behavioral of LMSU_testbench is
    signal clk, clk_anc, reset, clk_enable, adapt, ce_out, enb: std_logic := '0';
    constant t1 : time := 400ns;
    constant t2 : time := 10ns;
        
    signal LMSU_input, LMSU_error: std_logic_vector(23 downto 0) := (others => '0');
    signal LMSU_en : std_logic := '0';
    
    signal Wanc : vector_of_std_logic_vector24(0 to 11) := (others => (others => '0'));
    signal sine_out : std_logic_vector(23 downto 0) := (others => '0');
begin

    reset <= '0'; clk_enable <= '1';
    
    CLOCK_ANC : process
    begin
        clk_anc <= '0';
        wait for t1/2;
        clk_anc <= '1';
        wait for t1/2;
    end process;
    
    CLOCK_SYS : process
    begin
        clk <= '0';
        wait for t2/2;
        clk <= '1';
        wait for t2/2;
    end process;
    
    LMSU : entity work.LMS_UPDATE --Unit Under Test
    port map(
        clk_anc => clk_anc,
        clk => clk,
        reset => reset,
        enb => LMSU_en,
        X => LMSU_input,
        E => LMSU_error,
        adapt => adapt,
        W => Wanc
    );
        LMSU_input <= sine_out;
        LMSU_error <= std_logic_vector(shift_right(signed(sine_out),2));
        LMSU_en <= '1';
        adapt <= '1';
    
    SINE : entity work.sine_generator(amplitude_49)
    port map(
        clk => clk_anc,
        reset => reset,
        clk_enable => clk_enable,
        Out1 => sine_out
    );
    
end Behavioral;