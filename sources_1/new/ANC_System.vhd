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
USE work.anc_package.ALL;
Library xpm;
use xpm.vcomponents.all;

entity ANC_System is
    port(
        --fpga
        clk : in std_logic; --125Mhz
        clk_dsp : in std_logic;
        clk_anc : in std_logic; --10Khz
        reset : in std_logic;
        enable : in std_logic; --anc enable
        
        -- signals : fixed point, signed, 24 bit, 24 precision bits
        refMic_in : in std_logic_vector(23 downto 0);
        errMic_in : in std_logic_vector(23 downto 0);
        antiNoise_out : out std_logic_vector(23 downto 0);
        noise_out : out std_logic_vector(23 downto 0)
    );
end ANC_System;--

architecture rtl of ANC_System is
    signal clk_22Khz, clk_41Khz, clk_ila : std_logic := '0';
    signal refMic, errMic, antiNoise, noise : std_logic_vector(23 downto 0) := (others => '0');
	
    signal AF_REF_SUM : std_logic_vector(23 downto 0) := (others => '0'); --acoustic feedback output plus reference mic
    signal adapt, trainingMode: std_logic := '0';
    signal AntiNoiseAdapt, AntiNoiseAdapt_d1 : std_logic_vector(23 downto 0) := (others => '0');
    signal trainingNoise, sine_out_225Hz, sine_out_150Hz, sine_sum, rand_out: std_logic_vector(23 downto 0) := (others => '0');
    signal SINE_en, rand_en : std_logic := '0';
    
    signal stim_count : integer range 0 to 10000000 := 0;
    
    --secondary path filter
    signal SPF_en : std_logic := '0';
    signal SPF_output : std_logic_vector(23 downto 0) := (others => '0');
    --secondary path algorithm
    signal SPA_en : std_logic := '0';
    signal SPA_adapt : std_logic := '0';
        
    --primary path filter
    signal PPF_en : std_logic := '0';
    signal PPF_output, PPF_negative : std_logic_vector(23 downto 0) := (others => '0');
    --primary path algorithm
    signal PPA_en : std_logic := '0';
    signal PPA_adapt : std_logic := '0';
    
    --acoustic feedback filter
    signal AFF_en : std_logic := '0';
    signal AFF_output : std_logic_vector(23 downto 0) := (others => '0');
    --acoustic feedback algorithm
    signal AFA_en : std_logic := '0';
    signal AFA_adapt : std_logic := '0';
begin

    SIGNAL_ROUTING_BUFFERS : process(clk_anc)
    begin
        if rising_edge(clk_anc) then
            refMic <= refMic_in;
            errMic <= errMic_in;
            noise_out <= noise;
            antiNoise_out <= antiNoise;
            AntiNoiseAdapt_d1 <= AntiNoiseAdapt;
            if enable = '1' then
                AntiNoiseAdapt <= PPF_negative;
            else
                AntiNoiseAdapt <= (others => '0');
            end if;
            if trainingMode = '1' then
                noise <= (others => '0');
                antiNoise <= trainingNoise;
                SPA_en <= '1'; SPF_en <= '0';
                AFA_en <= '1'; AFF_en <= '0';
                PPA_en <= '0'; PPF_en <= '0';
            else
                SPA_en <= '0'; SPF_en <= enable;
                AFA_en <= '0'; AFF_en <= enable;
                PPA_en <= enable; PPF_en <= enable;
                noise <= sine_sum;
                antiNoise <= antiNoiseAdapt;
            end if;
        end if;
    end process;
   
    TRAIN_ADAPT_SEQUENCING : process(clk_anc)
    begin
        if rising_edge(clk_anc) then
            if stim_count < 1000000 then
                stim_count <= stim_count + 1; --625, 100000
                if stim_count > 625 AND stim_count < 100000 then
                    adapt <= '1';
                else
                    adapt <= '0';
                end if;
                if stim_count < 100000 then
                    trainingMode <= '1';
                else
                    trainingMode <= '0';
                end if;
            end if;
        end if;
    end process;
    
    AF_REF_SUM <= std_logic_vector( signed(refMic) - signed(AFF_output) );
    PPF_negative <= std_logic_vector( - signed(PPF_output) );
    
	PRIMARY_SOUND_PATH : entity work.primary_path
	generic map(L => 384, W => 16)
	port map(
		clk_anc => clk_anc,
		clk_dsp => clk_dsp,
		clk_ila => clk_ila,
		reset => reset,
		filt_enable => PPF_en,
		filt_input => AF_REF_SUM,
		filt_output => PPF_output,
		algo_enable => PPA_en,
		algo_input => SPF_output,
		algo_error => errMic,
		algo_adapt => PPA_adapt
	);
	   PPA_adapt <= (NOT trainingMode) AND enable;
	
	SECONDARY_SOUND_PATH : entity work.secondary_path
	generic map(L => 128, W => 8)
	port map(
		clk_anc => clk_anc,
		clk_dsp => clk_dsp,
		clk_ila => clk_ila,
		reset => reset,
		algo_enable => SPA_en,
		algo_input => trainingNoise,
		algo_desired => errMic,
		algo_adapt => SPA_adapt,
		filt_enable => SPF_en,
		filt_input => AF_REF_SUM,
		filt_output => SPF_output
	);
	   SPA_adapt <= trainingMode;
    
	ACOUSTIC_FEEDBACK_SOUND_PATH : entity work.secondary_path
	generic map(L => 128, W => 8)
	port map(
		clk_anc => clk_anc,
		clk_dsp => clk_dsp,
		clk_ila => clk_ila,
		reset => reset,
		algo_enable => AFA_en,
		algo_input => trainingNoise,
		algo_desired => refMic,
		algo_adapt => AFA_adapt,
		filt_enable => AFF_en,
		filt_input => AntiNoiseAdapt_d1,
		filt_output => AFF_output
	);
	   AFA_adapt <= trainingMode;
	
    TRAINING_NOISE : entity work.PRBS
    port map(clk => clk_22Khz, rst => reset, ce => rand_en, rand => rand_out);
    rand_en <= '1';
    trainingNoise <= std_logic_vector(shift_right(signed(rand_out), 6)); --divide 64x

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
    
--    DEBUG_SIGNALS_1 : ila_3
--    PORT MAP(
--        clk     => clk_ila,
--        probe0  => refMic,
--        probe1  => errMic,
--        probe2  => noise,
--        probe3  => antiNoise,
--        probe4  => trainingNoise, --secondary path filter out
--        probe5  => AFF_output, --acoustic feedback filter out
--        probe6  => PPF_output --primary path filter out
--    );
    
end rtl;