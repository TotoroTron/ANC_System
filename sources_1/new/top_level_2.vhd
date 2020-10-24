----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/20/2020 09:21:27 PM
-- Design Name: 
-- Module Name: top_level_2 - Behavioral
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

entity top_level_2 is
    port (
        clk : in std_logic; --freq = 22.5792 Mhz, period = 
        reset : in std_logic;

        --line out
        tx_mclk : out std_logic;
        tx_lrck : out std_logic;
        tx_sclk : out std_logic;
        tx_data : out std_logic;
        
        --line in
        rx_mclk : out std_logic;
        rx_lrck : out std_logic;
        rx_sclk : out std_logic;
        rx_data : in std_logic
    );
end top_level_2;

architecture Behavioral of top_level_2 is
    component clk_wiz_0 port(clk_in1 : in std_logic; clk_out1 : out std_logic); end component;
    signal clk_22Mhz ,clk_10Khz : std_logic := '0';
    signal toSpeaker, fromMicrophone : std_logic_vector(31 downto 0) := (others => '0');
    signal sine_out : std_logic_vector(23 downto 0);
    signal clk_enable : std_logic;
    signal ce_out : std_logic;
    signal tx_valid, tx_ready, tx_last : std_logic;
    signal rx_valid, rx_ready, rx_last : std_logic;
    signal count : natural;
    signal resetn : std_logic;
    signal rand_out : std_logic_vector(23 downto 0);
begin
    clk_enable <= '1';
    I2S_CONTROLLER : entity work.i2s_controller
    port map(
        clk => clk_22Mhz,
        s_axis_valid => rx_valid,
        s_axis_ready => rx_ready,
        s_axis_last => rx_last,
        m_axis_valid => tx_valid,
        m_axis_ready => tx_ready,
        m_axis_last => tx_last        
    );
    
    resetn <= '1';
    PMOD : entity work.axis_i2s2
    port map(
        axis_clk => clk_22Mhz,              --input
        axis_resetn => resetn,                 --input
        
        tx_axis_s_data => toSpeaker,        --input
        tx_axis_s_valid => tx_valid,        --input
        tx_axis_s_ready => tx_ready,        --output
        tx_axis_s_last => tx_last,          --input
        
        rx_axis_m_data => fromMicrophone,   --output
        rx_axis_m_valid => rx_valid,        --output
        rx_axis_m_ready => rx_ready,        --input
        rx_axis_m_last => rx_last,          --output
        
        tx_mclk => tx_mclk,                 --output
        tx_lrck => tx_lrck,                 --output
        tx_sclk => tx_sclk,                 --output
        tx_sdout => tx_data,                --output
        
        rx_mclk => rx_mclk,                 --output
        rx_lrck => rx_lrck,                 --output
        rx_sclk => rx_sclk,                 --output
        rx_sdin => rx_data                  --input
    );
    
    SINE_CLK : process(clk)
    begin
        if rising_edge(clk) then
            if count < 624 then
                count <= count + 1;
            else
                clk_10Khz <= NOT clk_10Khz;
                count <= 0;
            end if;
        end if;
    end process;
    
    RAND_SIGNAL : entity work.PRBS
    port map(
        clk => clk,
        rst => reset,
        ce => clk_enable,
        rand => rand_out        
    );
    toSpeaker(23) <= rand_out(23);
    toSpeaker(22 downto 0) <= "0000000000000000" & rand_out(22 downto 16);

--    SINE_GEN : entity work.sine_generator
--    port map(
--        clk => clk_10Khz,
--        reset => reset,
--        clk_enable => clk_enable,
--        ce_out => ce_out,
--        Out1 => sine_out
--    );
--    toSpeaker(23 downto 0) <= sine_out;
    
    PMOD_CLK : clk_wiz_0
    port map(
        clk_in1 => clk,
        clk_out1 => clk_22Mhz
    );

end Behavioral;
