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
    signal clk_100Mhz, clk_22Mhz, clk_44Khz, clk_100Khz, resetn : std_logic := '0';
    signal count_44Khz, count_100Khz : natural range 0 to 2300;
    signal reset, clk_enable, sw0, btn0, ce_out : std_logic;
    signal noiseSpkr, antiNoiseSpkr, refMic, errMic, sine_out, rand_out : std_logic_vector(23 downto 0);
    constant clk_period : time := 10ns;
    signal noisy_sine : std_logic_vector(23 downto 0);
begin

    TEST_PROC : process
    begin
        btn0 <= '0'; sw0 <= '0'; reset <= '0';
        clk_enable <= '1';
        for i in 0 to 1400 loop
        wait until rising_edge(clk_44Khz);
        end loop;
        sw0 <= '1';
        wait;
    end process;
    
    sine : entity work.sine_generator
    port map(
        clk => clk_44Khz,
        reset => reset,
        clk_enable => clk_enable,
        ce_out => ce_out,
        Out1 => sine_out
    );
    
    random : entity work.PRBS
    port map(
        clk => clk_44Khz,
        rst => reset,
        ce => clk_enable,
        rand => rand_out
    );

    CLK_GEN_100Khz : process(clk_100Mhz)
    begin
        if rising_edge(clk_100Mhz) then
            if count_100Khz = 499 then
                clk_100Khz <= NOT clk_100Khz;
                count_100Khz <= 0;
            else
                count_100Khz <= count_100Khz + 1;
            end if;
        end if;
    end process;
    
    ANC_SYSTEM : entity work.ANC_System
    port map(
        clk_44Khz => clk_44Khz,
        clk_100Khz => clk_100Khz,
        btn0 => btn0,
        sw0 => sw0,
        refMic => refMic(23 downto 0),
        errMic => errMic(23 downto 0),
        antiNoise => antiNoiseSpkr(23 downto 0),
        noise => noiseSpkr(23 downto 0)
    );
    errMic(23 downto 0) <= rand_out; refMic(23 downto 0) <= sine_out;
    
    CLOCK: process
    begin
        clk_100Mhz <= '0';
        wait for clk_period/2;
        clk_100Mhz <= '1';
        wait for clk_period/2;
    end process;
    
    CLK_GEN_44Khz : process(clk_100Mhz)
    begin
        if rising_edge(clk_100Mhz) then
            if count_44Khz = 2267 then
                clk_44Khz <= NOT clk_44Khz;
                count_44Khz <= 0;
            else
                count_44Khz <= count_44Khz + 1;
            end if;
        end if;
    end process;

end Behavioral;
