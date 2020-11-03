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
        clk_100Mhz : in std_logic;
        btn0 : in std_logic;
        sw0 : in std_logic;
        
        -- signals : fixed point, signed, 24 bit, binary point at 24
        refMic : in std_logic_vector(23 downto 0);
        errMic : in std_logic_vector(23 downto 0);
        antiNoise : out std_logic_vector(23 downto 0) := (others => '0');
        noise : out std_logic_vector(23 downto 0)
    );
end ANC_System;--

architecture rtl of ANC_System is
    signal reset, clk_44Khz, clk_22Khz, clk_41Khz : std_logic := '0';
    signal count_44Khz, count_22Khz, count_41Khz : natural range 0 to 65535;
    signal sum1_out : std_logic_vector(23 downto 0) := (others => '0');
    
    signal adapt, enable, trainingMode: std_logic := '0';

    signal Wanc : vector_of_std_logic_vector24(0 TO 11) := (others => (others => '0'));
    signal Wsp : vector_of_std_logic_vector24(0 TO 11) := (others => (others => '0'));
    signal Waf : vector_of_std_logic_vector24(0 TO 11) := (others => (others => '0'));
    
    signal nlms_adapt, nlms_ce_out, nlms_clk_en : std_logic := '0';
    signal SP_en, SP_ceOut : std_logic := '0';
    signal SP_FilterOut : std_logic_vector(23 downto 0) := (others => '0');

    signal ANC_en, ANC_ceOut : std_logic := '0';
    signal ANC_FilterOut, ANC_FilterOut_Negative : std_logic_vector(23 downto 0) := (others => '0');
    
    signal AF_en, AF_ceOut : std_logic := '0';
    signal AF_FilterOut : std_logic_vector(23 downto 0) := (others => '0');
    
    signal AntiNoiseAdapt, AntiNoiseAdaptDelayed : std_logic_vector(23 downto 0) := (others => '0');
    
    signal SPE_clkEnable, SPE_ce_out : std_logic := '0';
    signal AFE_clkEnable, AFE_ce_out : std_logic := '0';
    
    signal trainingNoise, sine_out_225Hz, sine_out_150Hz, sine_sum, rand_out: std_logic_vector(23 downto 0) := (others => '0');
    signal SINE_en, SINE_ceOut, rand_en : std_logic := '0';
    
    signal count : integer range 0 to 1000000 := 0;
begin

    DEBUGGER : ila_0
    PORT MAP(
        clk => clk_100Mhz,
        probe0 => Waf(0),
        probe1 => Waf(1),
        probe2 => Waf(2),
        probe3 => Waf(3),
        probe4 => Waf(4),
        probe5 => Waf(5),
        probe6 => Waf(6),
        probe7 => Waf(7),
        probe8 => Waf(8),
        probe9 => Waf(9),
        probe10 => Waf(10),
        probe11 => Waf(11)
    );
    
    CLK_GEN_44Khz : process(clk_100Mhz) --44.1 Khz
    begin
        if rising_edge(clk_100Mhz) then
        if count_44Khz = 1417 then
            clk_44Khz <= NOT clk_44Khz;
            count_44Khz <= 0;
        else
            count_44Khz <= count_44Khz + 1;
        end if;
        end if;
    end process;
    
    CLK_GEN_22Khz : process(clk_100Mhz) --22.5Khz
    begin
        if rising_edge(clk_100Mhz) then
        if count_22Khz = 2778 then
            clk_22Khz <= NOT clk_22Khz;
            count_22Khz <= 0;
        else
            count_22Khz <= count_22Khz + 1;
        end if;
        end if;
    end process;
    
    CLK_GEN_41Khz : process(clk_100Mhz) --15Khz
    begin
        if rising_edge(clk_100Mhz) then
        if count_41Khz = 4167 then
            clk_41Khz <= NOT clk_41Khz;
            count_41Khz <= 0;
        else
            count_41Khz <= count_41Khz + 1;
        end if;
        end if;
    end process;
    
    enable <= sw0;
    reset <= btn0;
    sum1_out <= std_logic_vector( signed(refMic) - signed(AF_FilterOut) );
    ANC_FilterOut_Negative <= std_logic_vector(-signed(ANC_FilterOut));
    
    REGISTER_PROCESS : process(clk_44Khz)
    begin
        if rising_edge(clk_44Khz) then
            AntiNoiseAdaptDelayed <= AntiNoiseAdapt;
            if enable = '1' then AntiNoiseAdapt <= ANC_FilterOut_Negative; else AntiNoiseAdapt <= (others => '0'); end if;
            if trainingMode = '1' then antiNoise <= trainingNoise; else antiNoise <= antiNoiseAdapt; end if;
            if trainingMode = '1' then noise <= (others => '0'); else noise <= sine_sum; end if;           
        end if;
    end process;
    
    STIMULUS : process(clk_44Khz)
    begin
        if rising_edge(clk_44Khz) then
            if count < 960001 then
                count <= count + 1; --625, 200000
                if count > 625 AND count < 960000 then adapt <= '1'; else adapt <= '0'; end if;
                if count < 960000 then trainingMode <= '1'; else trainingMode <= '0'; end if;
            end if;
        end if;
    end process;
    
    SP_en <= '1';
    SECONDARY_PATH_FILTER : entity work.Discrete_FIR_Filter_24
    port map(
        clk => clk_44Khz,
        reset => reset,
        enb => SP_en,
        Discrete_FIR_Filter_in => sum1_out,
        Discrete_FIR_Filter_coeff => Wsp,
        Discrete_FIR_Filter_out => SP_FilterOut
    );
    
    ANC_en <= '1';
    ANC_FILTER : entity work.Discrete_FIR_Filter_24
    port map(
        clk => clk_44Khz,
        reset => reset,
        enb => ANC_en,
        Discrete_FIR_Filter_in => sum1_out,
        Discrete_FIR_Filter_coeff => Wanc,
        Discrete_FIR_Filter_out => ANC_FilterOut
    );
    
    AF_en <= '1';
    ACOUSTIC_FEEDBACK_FILTER : entity work.Discrete_FIR_Filter_24
    port map(
        clk => clk_44Khz,
        reset => reset,
        enb => AF_en,
        Discrete_FIR_Filter_in => antiNoiseAdaptDelayed,
        Discrete_FIR_Filter_coeff => Waf,
        Discrete_FIR_Filter_out => AF_FilterOut
    );
    
    nlms_adapt <= (NOT trainingMode) AND enable;
    nlms_clk_en <= '1';
    LMS_UPDATE : entity work.LMSUpdate
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
    SPE_ce_out <= adapt;
    SECONDARY_PATH_ESTIMATION : entity work.LMS_Filter_24
    port map(
        clk => clk_44Khz,
        reset => reset,
        clk_enable => SPE_clkEnable,
        input => trainingNoise,
        desired => errMic,
        adapt => adapt,
        ce_out => SPE_ce_out,
        weights => Wsp
    );
    
    AFE_clkEnable <= adapt;
    AFE_ce_out <= adapt;
    ACOUSTIC_FEEDBACK_ESTIMATION : entity work.LMS_Filter_24
    port map(
        clk => clk_44Khz,
        reset => reset,
        clk_enable => AFE_clkEnable,
        input => trainingNoise,
        desired => refMic,
        adapt => adapt,
        ce_out => AFE_ce_out,
        weights => Waf
    );
    
    rand_en <= '1';
    TRAINING_NOISE : entity work.PRBS
    port map(
        clk => clk_44Khz,
        rst => reset,
        ce => rand_en,
        rand => rand_out
    );
    trainingNoise <= std_logic_vector(shift_right(signed(rand_out), 4));
    
    SINE_en <= '1';
    sine_sum <= std_logic_vector(signed(sine_out_225Hz) + signed(sine_out_150Hz));
    
    SINE_WAVE_225 : entity work.sine_generator(amplitude_20) --225Hz sine output
    port map(
        clk => clk_22Khz,
        reset => reset,
        clk_enable => SINE_en,
        ce_out => SINE_ceOut,
        Out1 => sine_out_225Hz
    );
    
    SINE_WAVE_150 : entity work.sine_generator(amplitude_25) --150Hz sine output
    port map(
        clk => clk_41Khz,
        reset => reset,
        clk_enable => SINE_en,
        ce_out => SINE_ceOut,
        Out1 => sine_out_150Hz
    );
    
end rtl;
