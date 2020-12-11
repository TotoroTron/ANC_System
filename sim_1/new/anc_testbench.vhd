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
use ieee.numeric_std.all;
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
    component clk_wiz_0 port(clk_in1 : in std_logic; clk_out1 : out std_logic); end component;
    constant t1 : time := 100ns; --anc
    constant t2 : time := 0.1ns; --dsp
    constant t3 : time := 10ns; --sine
    signal clk, clk_anc, clk_dsp, clk_sine, resetn : std_logic := '0';
    signal count_44Khz, count_100Khz : natural range 0 to 2300;
    signal reset, clk_enable, sw0, btn0, ce_out : std_logic;
    signal noiseSpkr, antiNoiseSpkr, refMic, errMic, sine_out, rand_out : std_logic_vector(23 downto 0);
    constant clk_period : time := 10ns;
    signal noisy_sine : std_logic_vector(23 downto 0);
    signal enable : std_logic;
begin

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
    CLOCK_SINE: process
    begin
        clk_sine <= '0';
        wait for t3/2;
        clk_sine <= '1';
        wait for t3/2;
    end process;
    
    sine : entity work.sine_generator(amplitude_15)
    port map(
        clk => clk_sine,
        reset => reset,
        clk_enable => clk_enable,
        Out1 => sine_out
    );
    
    random : entity work.PRBS
    port map(
        clk => clk_anc,
        rst => reset,
        ce => clk_enable,
        rand => rand_out
    );
        clk_enable <= '1';
        reset <= '0';

    clk_10Khz : entity work.clk_div --22.5Khz drives 225Hz sine, training noise
    generic map(count => 10000) port map(clk_in => clk, clk_out => clk_anc);
    
    ANC_SYSTEM : entity work.ANC_System
    port map(
        clk => clk,
        clk_dsp => clk_dsp,
        clk_anc => clk_anc,
        reset => reset,
        enable => enable,
        refMic_in => refMic(23 downto 0),
        errMic_in => errMic(23 downto 0),
        antiNoise_out => antiNoiseSpkr(23 downto 0),
        noise_out => noiseSpkr(23 downto 0)
    );
        errMic(23 downto 0) <= rand_out;
        refMic(23 downto 0) <= sine_out;
        enable <= '1';

end Behavioral;
