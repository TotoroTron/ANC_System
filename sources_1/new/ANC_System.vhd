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
    signal reset, clk_44Khz, clk_22Khz, clk_41Khz : std_logic := '0';
    signal count_22Khz, count_41Khz : natural range 0 to 65535 := 0;
    signal count_44Khz : unsigned(14 downto 0) := (others => '0');
    signal refMic, errMic, antiNoise, noise : std_logic_vector(23 downto 0);
    signal sum1_out : std_logic_vector(23 downto 0);
    signal adapt, enable, trainingMode: std_logic := '0';
    signal Wanc : vector_of_std_logic_vector24(0 TO 31);-- := (others => (others => '0'));
    signal Wsp : vector_of_std_logic_vector24(0 TO 11);-- := (others => (others => '0'));
    signal Waf : vector_of_std_logic_vector24(0 TO 11);-- := (others => (others => '0'));
    
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
    
    SIGNAL_BUFFER : process(clk_44Khz)
    begin
        if rising_edge(clk_44Khz) then
            refMic <= refMic_in; errMic <= errMic_in; noise_out <= noise; antiNoise_out <= antiNoise;
        end if;
    end process;
    
    DEBUGGER_WANC : ila_0
    PORT MAP(
        clk     => dbg_count(8),
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
        probe11 => Wanc(11),
        probe12 => Wanc(12),
        probe13 => Wanc(13),
        probe14 => Wanc(14),
        probe15 => Wanc(15),
        probe16 => Wanc(16),
        probe17 => Wanc(17),
        probe18 => Wanc(18),
        probe19 => Wanc(19),
        probe20 => Wanc(20),
        probe21 => Wanc(21),
        probe22 => Wanc(22),
        probe23 => Wanc(23),
        probe24 => Wanc(24),
        probe25 => Wanc(25),
        probe26 => Wanc(26),
        probe27 => Wanc(27),
        probe28 => Wanc(28),
        probe29 => Wanc(29),
        probe30 => Wanc(30),
        probe31 => Wanc(31)
    );
    
    DEBUGGER_SIG : ila_1
    PORT MAP(
        clk     => dbg_count(8),
        probe0  => SP_FilterOut,
        probe1  => AF_FilterOut,
        probe2  => ANC_FilterOut,
        probe3  => ANC_FilterOut_Negative,
        probe4  => errMic,
        probe5  => refMic,
        probe6  => noise,
        probe7  => antiNoise,
        probe8  => antiNoise,
        probe9  => sine_sum,
        probe10 => sine_out_150Hz,
        probe11 => sine_out_225Hz,
        probe12 => enable
    );
    
    DEBUG_CLK : process(clk)
    begin
        if rising_edge(clk) then
            dbg_count <= dbg_count + 1;
        end if;
    end process;
    
    CLK_GEN_44Khz : process(clk) --44.1 Khz
    begin
        if rising_edge(clk) then
            count_44Khz <= count_44Khz + 1;
        end if;
    end process;
    clk_44Khz <= count_44Khz(14);
    
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
            if stim_count < 80001 then
                stim_count <= stim_count + 1; --625, 200000
                if stim_count > 625 AND stim_count < 80000 then adapt <= '1'; else adapt <= '0'; end if;
                if stim_count < 80000 then trainingMode <= '1'; else trainingMode <= '0'; end if;
            end if;
        end if;
    end process;
    
    enable <= sw0;
    reset <= btn0;
    sum1_out <= std_logic_vector( signed(refMic) - signed(AF_FilterOut) );
    ANC_FilterOut_Negative <= std_logic_vector( -signed(ANC_FilterOut) );
    
    SECONDARY_PATH_FILTER : entity work.Discrete_FIR_Filter_24(taps_12)
    port map(
        clk => clk_44Khz,
        reset => reset,
        enb => SP_en,
        Discrete_FIR_Filter_in => sum1_out,
        Discrete_FIR_Filter_coeff => Wsp,
        Discrete_FIR_Filter_out => SP_FilterOut
    );
        SP_en <= '1';
        
    ANC_FILTER : entity work.Discrete_FIR_Filter_32(taps_32)
    port map(
        clk => clk_44Khz,
        reset => reset,
        enb => ANC_en,
        Discrete_FIR_Filter_in => sum1_out,
        Discrete_FIR_Filter_coeff => Wanc,
        Discrete_FIR_Filter_out => ANC_FilterOut
    );
        ANC_en <= '1';
        
    ACOUSTIC_FEEDBACK_FILTER : entity work.Discrete_FIR_Filter_24(taps_12)
    port map(
        clk => clk_44Khz,
        reset => reset,
        enb => AF_en,
        Discrete_FIR_Filter_in => antiNoiseAdaptDelayed,
        Discrete_FIR_Filter_coeff => Waf,
        Discrete_FIR_Filter_out => AF_FilterOut
    );
        AF_en <= '1';
        
    LMS_UPDATE : entity work.LMSUpdate
    port map(
        clk => clk_44Khz,
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
        clk => clk_44Khz,
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
        clk => clk_44Khz,
        reset => reset,
        clk_enable => AFE_en,
        input => trainingNoise,
        desired => refMic,
        adapt => adapt,
        weights => Waf
    );
        AFE_en <= adapt;
        
    TRAINING_NOISE : entity work.PRBS
    port map(
        clk => clk_44Khz,
        rst => reset,
        ce => rand_en,
        rand => rand_out
    );
        rand_en <= '1';
        trainingNoise <= rand_out; --std_logic_vector(shift_right(signed(rand_out), 2));

    SINE_WAVE_225 : entity work.sine_generator(amplitude_15) --225Hz sine output
    port map(
        clk => clk_22Khz,
        reset => reset,
        clk_enable => SINE_en,
        Out1 => sine_out_225Hz
    );
    
    SINE_WAVE_150 : entity work.sine_generator(amplitude_25) --150Hz sine output
    port map(
        clk => clk_41Khz,
        reset => reset,
        clk_enable => SINE_en,
        Out1 => sine_out_150Hz
    );
        SINE_en <= '1';
        sine_sum <= std_logic_vector(signed(sine_out_225Hz) + signed(sine_out_150Hz));
        
    CLK_GEN_22Khz : process(clk) --22.5Khz
    begin
        if rising_edge(clk) then
        if count_22Khz = 278 then
            clk_22Khz <= NOT clk_22Khz;
            count_22Khz <= 0;
        else
            count_22Khz <= count_22Khz + 1;
        end if;
        end if;
    end process;
    
    CLK_GEN_41Khz : process(clk) --15Khz
    begin
        if rising_edge(clk) then
        if count_41Khz = 417 then
            clk_41Khz <= NOT clk_41Khz;
            count_41Khz <= 0;
        else
            count_41Khz <= count_41Khz + 1;
        end if;
        end if;
    end process;
    
end rtl;
