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
        clk : in std_logic; --125Mhz
        clk_22Mhz : in std_logic;
        btn0 : in std_logic;
        sw0 : in std_logic;
        
        -- signals : fixed point, signed, 24 bit, binary point at 24
        refMic_in : in std_logic_vector(23 downto 0);
        errMic_in : in std_logic_vector(23 downto 0);
        antiNoise_out : out std_logic_vector(23 downto 0);
        noise_out : out std_logic_vector(23 downto 0)
    );
end ANC_System;--

architecture rtl of ANC_System is
    signal reset, clk_10Khz, clk_22Khz, clk_41Khz, clk_ila : std_logic := '0';
    signal refMic, errMic, antiNoise, noise : std_logic_vector(23 downto 0);
    signal AF_REF_SUM : std_logic_vector(23 downto 0);
    signal adapt, enable, trainingMode: std_logic := '0';
    signal Wanc : vector_of_std_logic_vector24(0 TO 11);-- := (others => (others => '0'));
    signal Wsp : vector_of_std_logic_vector24(0 TO 23);-- := (others => (others => '0'));
    signal Waf : vector_of_std_logic_vector24(0 TO 23);-- := (others => (others => '0'));
    
    signal LMSU_adapt, LMSU_en : std_logic := '0';
    signal SP_en, SP_ceOut : std_logic := '0';
    signal SP_FilterOut : std_logic_vector(23 downto 0);

    signal ANC_en : std_logic := '0';
    signal ANC_FilterOut, ANC_FilterOut_Negative : std_logic_vector(23 downto 0);
    
    signal AF_en, AF_ceOut : std_logic := '0';
    signal AF_FilterOut : std_logic_vector(23 downto 0);
    
    signal AntiNoiseAdapt, AntiNoiseAdaptDelayed : std_logic_vector(23 downto 0);
    
    signal SPE_en, SPE_ce_out : std_logic := '0';
    signal AFE_en : std_logic := '0';
    
    signal trainingNoise, sine_out_225Hz, sine_out_150Hz, sine_sum, rand_out: std_logic_vector(23 downto 0);
    signal SINE_en, rand_en : std_logic := '0';
    
    signal stim_count : integer range 0 to 1000000 := 0;
    signal dbg_count : unsigned(9 downto 0) := (others => '0');
begin
    
    SIGNAL_ROUTING_BUFFERS : process(clk_10Khz)
    begin
        if rising_edge(clk_10Khz) then
            refMic <= refMic_in; errMic <= errMic_in; noise_out <= noise; antiNoise_out <= antiNoise;
            AntiNoiseAdaptDelayed <= AntiNoiseAdapt;
            if enable = '1' then AntiNoiseAdapt <= ANC_FilterOut_Negative; else AntiNoiseAdapt <= (others => '0'); end if;
            if trainingMode = '1' then antiNoise <= trainingNoise; else antiNoise <= antiNoiseAdapt; end if;
            if trainingMode = '1' then noise <= (others => '0'); else noise <= sine_sum; end if;    
        end if;
    end process;
   
    TRAINING_ADAPT_SEQUENCING : process(clk_10Khz)
    begin
        if rising_edge(clk_10Khz) then
            if stim_count < 100001 then
                stim_count <= stim_count + 1; --625, 200000
                if stim_count > 625 AND stim_count < 100000 then adapt <= '1'; else adapt <= '0'; end if;
                if stim_count < 100000 then trainingMode <= '1'; else trainingMode <= '0'; end if;
            end if;
        end if;
    end process;
    
    enable <= sw0;
    reset <= btn0;
    AF_REF_SUM <= std_logic_vector( signed(refMic) - signed(AF_FilterOut) );
    ANC_FilterOut_Negative <= std_logic_vector( -signed(ANC_FilterOut) );
    
    SECONDARY_PATH_FILTER : entity work.Discrete_FIR_Filter_24
    port map(
        clk => clk_10Khz,
        reset => reset,
        enb => SP_en,
        Discrete_FIR_Filter_in => AF_REF_SUM,
        Discrete_FIR_Filter_coeff => Wsp,
        Discrete_FIR_Filter_out => SP_FilterOut
    );
        SP_en <= '1';
        
    ANC_FILTER : entity work.Discrete_FIR_Filter_12
    port map(
        clk => clk_10Khz,
        reset => reset,
        enb => ANC_en,
        Discrete_FIR_Filter_in => AF_REF_SUM,
        Discrete_FIR_Filter_coeff => Wanc,
        Discrete_FIR_Filter_out => ANC_FilterOut
    );
        ANC_en <= '1';
        
    ACOUSTIC_FEEDBACK_FILTER : entity work.Discrete_FIR_Filter_24
    port map(
        clk => clk_10Khz,
        reset => reset,
        enb => AF_en,
        Discrete_FIR_Filter_in => antiNoiseAdaptDelayed,
        Discrete_FIR_Filter_coeff => Waf,
        Discrete_FIR_Filter_out => AF_FilterOut
    );
        AF_en <= '1';
        
    LMS_UPDATE : entity work.LMS_Update_12
    port map(
        clk => clk_10Khz,
        reset => reset,
        enb => LMSU_en,
        X => SP_FilterOut,
        E => errMic,
        adapt => LMSU_adapt,
        W => Wanc
    );
        LMSU_adapt <= (NOT trainingMode) AND enable;
        LMSU_en <= LMSU_adapt;
    
    SECONDARY_PATH_ESTIMATION : entity work.LMS_Filter_24
    port map(
        clk => clk_10Khz,
        reset => reset,
        clk_enable => SPE_en,
        input => trainingNoise,
        desired => errMic,
        adapt => adapt,
        weights => Wsp
    );
        SPE_en <= adapt;
    
    ACOUSTIC_FEEDBACK_ESTIMATION : entity work.LMS_Filter_24
    port map(
        clk => clk_10Khz,
        reset => reset,
        clk_enable => AFE_en,
        input => trainingNoise,
        desired => refMic,
        adapt => adapt,
        weights => Waf
    );
        AFE_en <= adapt;
        
    TRAINING_NOISE : entity work.PRBS
    port map(clk => clk_22Khz, rst => reset, ce => rand_en, rand => rand_out);
    rand_en <= '1';
    trainingNoise <= rand_out; --std_logic_vector(shift_right(signed(rand_out), 2));

    SINE_WAVE_225 : entity work.sine_generator(amplitude_15) --225Hz sine output
    port map(clk => clk_22Khz, reset => reset, clk_enable => SINE_en, Out1 => sine_out_225Hz);
    SINE_WAVE_150 : entity work.sine_generator(amplitude_25) --150Hz sine output, 1K sample period
    port map(clk => clk_41Khz, reset => reset, clk_enable => SINE_en, Out1 => sine_out_150Hz);
    SINE_en <= '1';
    sine_sum <= std_logic_vector(signed(sine_out_225Hz) + signed(sine_out_150Hz));
    
    CLK_GEN_22Khz : entity work.clk_div --22.5Khz drives 225Hz sine, training noise
    generic map(count => 556) port map(clk_in => clk, clk_out => clk_22Khz);
    CLK_GEN_41Khz : entity work.clk_div --15Khz drives 150Hz sine
    generic map(count => 834) port map(clk_in => clk, clk_out => clk_41Khz);
    CLK_GEN_ILA : entity work.clk_div --375Khz drives ILA debugger. clock must be >2.5x JTAG clk
    generic map(count => 334) port map(clk_in => clk, clk_out => clk_ila);
    CLK_GEN_10Khz : entity work.clk_div --10Khz drives ANC system
    generic map(count => 12500) port map(clk_in => clk, clk_out => clk_10Khz);
    
    DEBUGGER_WANC : ila_0
    PORT MAP(
        clk     => clk_ila,
        probe0  => Wanc(0),
        probe1  => Wanc(1),
        probe2  => Wanc(2),
        probe3  => Wanc(3),
        probe4  => Wanc(4),
        probe5  => Wanc(5),
        probe6  => Wanc(6),
        probe7  => Wanc(7),
        probe8  => Wanc(8),
        probe9  => Wanc(9),
        probe10 => Wanc(10),
        probe11 => Wanc(11)
    );
    
    DEBUGGER_SIGNALS : ila_1
    PORT MAP(
        clk     => clk_ila,
        probe0  => refMic,
        probe1  => errMic,
        probe2  => noise,
        probe3  => antiNoise,
        probe4  => SP_FilterOut,
        probe5  => AF_FilterOut,
        probe6  => ANC_FilterOut
    );
end rtl;