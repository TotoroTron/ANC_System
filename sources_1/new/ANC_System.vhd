----------------------------------------------------------------------------------
-- Company: 
-- Engineers: Brian Cheng
-- 
-- Create Date: 10/17/2020 10:59:32 PM
-- Design Name: 
-- Module Name: ANC_System - rtl
-- Project Name: ANC_System
-- Target Devices: Arty Z7-20 (xc7z020clg400-1)
-- Tool Versions: Vivado 2020.1
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

entity ANC_System is
    port(
        --fpga
        clk_44Khz : in std_logic;
        clk_100Khz : in std_logic;
        btn0 : in std_logic;
        sw0 : in std_logic;
        
        refMic : in std_logic_vector(23 downto 0);
        errMic : in std_logic_vector(23 downto 0);
        antiNoise : out std_logic_vector(23 downto 0);
        noise : out std_logic_vector(23 downto 0)
    );
end ANC_System;--

architecture rtl of ANC_System is
    signal reset : std_logic;
    signal sum1_out : std_logic_vector(23 downto 0);
    
    signal adapt, enable, trainingMode : std_logic;

    signal Wanc : vector_of_std_logic_vector24(0 TO 11);
    signal Wsp : vector_of_std_logic_vector24(0 TO 11);
    signal Waf : vector_of_std_logic_vector24(0 TO 11);
    
    signal nlms_adapt, nlms_ce_out, nlms_clk_en : std_logic;
    signal SP_en, SP_ceOut : std_logic;
    signal SP_FilterOut : std_logic_vector(23 downto 0);

    signal ANC_en, ANC_ceOut : std_logic;
    signal ANC_FilterOut, ANC_FilterOut_Negative : std_logic_vector(23 downto 0);
    
    signal AF_en, AF_ceOut : std_logic;
    signal AF_FilterOut : std_logic_vector(23 downto 0);
    
    signal AntiNoiseAdapt : std_logic_vector(23 downto 0);
    
    signal SPE_clkEnable, SPE_ce_out : std_logic;
    signal AFE_clkEnable, AFE_ce_out : std_logic;
    
    signal trainingNoise, sine_out : std_logic_vector(23 downto 0);
    signal SINE_en, SINE_ceOut : std_logic;
    
    signal count : integer range 0 to 10000000 := 0;
begin
    
    enable <= sw0;
    reset <= btn0;
    
    sum1_out <= std_logic_vector( signed(refMic) - signed(AF_FilterOut) );
    ANC_FilterOut_Negative <= std_logic_vector(-signed(ANC_FilterOut));
    with enable select AntiNoiseAdapt <= ANC_FilterOut_Negative when '1', (others => '0') when others;
    
    with trainingMode select antiNoise <= antiNoiseAdapt when '1', trainingNoise when others;
    with trainingMode select noise <= sine_out when '1', (others => '0') when others;
    
    STIMULUS : process(clk_44Khz)
    begin
        if rising_edge(clk_44Khz) then
            if count < 200001 then
                count <= count + 1;
                if count > 625 AND count < 200000 then adapt <= '1'; else adapt <= '0'; end if;
                if count < 200000 then trainingMode <= '1'; else trainingMode <= '0'; end if;
            end if;
        end if;
    end process;
    
    SP_en <= '1';
    SECONDARY_PATH_FILTER : entity work.FIR_Filter_Subsystem
    port map(
        clk => clk_44Khz,
        reset => reset,
        clk_enable => SP_en,
        input => sum1_out,
        coeff => Wsp,
        ce_out => SP_ceOut,
        output => SP_FilterOut
    );
    
    ANC_en <= '1';
    ANC_FILTER : entity work.FIR_Filter_Subsystem
    port map(
        clk => clk_44Khz,
        reset => reset,
        clk_enable => ANC_en,
        input => sum1_out,
        coeff => Wanc,
        ce_out => ANC_ceOut,
        output => ANC_FilterOut
    );
    
    AF_en <= '1';
    ACOUSTIC_FEEDBACK_FILTER : entity work.FIR_Filter_Subsystem
    port map(
        clk => clk_44Khz,
        reset => reset,
        clk_enable => AF_en,
        input => antiNoiseAdapt,
        coeff => Waf,
        ce_out => AF_ceOut,
        output => AF_FilterOut
    );
    
    nlms_adapt <= (NOT trainingMode) AND enable;
    nlms_clk_en <= SP_ceOut;
    NLMS_UPDATE : entity work.LMSUpdate
    port map(
        clk => clk_44Khz,
        reset => reset,
        enb => nlms_clk_en,
        X => SP_FilterOut,
        E => errMic,
        adapt => nlms_adapt,
        W => Wanc
    );
    
    SPE_clkEnable <= adapt;
    SECONDARY_PATH_ESTIMATION : entity work.LMSFilter
    port map(
        clk => clk_44Khz,
        reset => reset,
        clk_enable => SPE_clkEnable,
        In1 => trainingNoise,
        In2 => errMic,
        ce_out => SPE_ce_out,
        Out3 => Wsp
    );
    
    AFE_clkEnable <= adapt;
    ACOUSTIC_FEEDBACK_ESTIMATION : entity work.LMSFilter
    port map(
        clk => clk_44Khz,
        reset => reset,
        clk_enable => AFE_clkEnable,
        In1 => trainingNoise,
        In2 => refMic,
        ce_out => AFE_ce_out,
        Out3 => Waf
    );
    
    TRAINING_NOISE : entity work.PRBS
    port map(
        clk => clk_44Khz,
        rst => reset,
        ce => trainingMode,
        rand => trainingNoise
    );
    
    SINE_en <= trainingMode;
    SINE_WAVE : entity work.sine_generator
    port map(
        clk => clk_100Khz,
        reset => reset,
        clk_enable => SINE_en,
        ce_out => SINE_ceOut,
        Out1 => sine_out
    );
    
end rtl;
