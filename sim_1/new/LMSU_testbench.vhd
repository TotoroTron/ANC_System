
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.top_level_pkg.ALL;


entity LMSU_testbench is
--  Port ( );
end LMSU_testbench;
--
architecture Behavioral of LMSU_testbench is
    signal clk_sine, clk_dsp, clk_anc, reset, clk_enable, adapt, ce_out, enb: std_logic := '0';
    constant t1 : time := 100ns;
    constant t3 : time := 10ns;
    constant t2 : time := 0.1ns;
        
    signal LMSU1_input, LMSU1_error: std_logic_vector(23 downto 0) := (others => '0');
    signal LMSU1_en : std_logic := '0';
    
    signal LMSU2_input, LMSU2_error: std_logic_vector(23 downto 0) := (others => '0');
    signal LMSU2_en : std_logic := '0';
    
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
    
    CLOCK_DSP : process
    begin
        clk_dsp <= '0';
        wait for t2/2;
        clk_dsp <= '1';
        wait for t2/2;
    end process;
    
    CLOCK_SINE : process
    begin
        clk_sine <= '0';
        wait for t3/2;
        clk_sine <= '1';
        wait for t3/2;    
    end process;
    
    LMSU1 : entity work.LMS_UPDATE_12 --Unit Under Test
    port map(
        clk => clk_anc,
        reset => reset,
        enb => LMSU1_en,
        X => LMSU1_input,
        E => LMSU1_error,
        adapt => adapt,
        W => Wanc
    );
        LMSU1_input <= sine_out;
        LMSU1_error <= std_logic_vector(shift_right(signed(sine_out),2));
        LMSU1_en <= '1';
        adapt <= '1';
    
    SINE : entity work.sine_generator(amplitude_49)
    port map(
        clk => clk_sine,
        reset => reset,
        clk_enable => clk_enable,
        Out1 => sine_out
    );
    
end Behavioral;