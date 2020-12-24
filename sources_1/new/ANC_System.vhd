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
        adapt : in std_logic; --anc adapt enable
        
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
	
    signal AF_REF_SUM : std_logic_vector(23 downto 0) := (others => '0');
    signal AntiNoiseAdapt : std_logic_vector(23 downto 0) := (others => '0');
    signal training_noise : std_logic_vector(23 downto 0) := (others => '0');
    signal sine_out_225Hz : std_logic_vector(23 downto 0) := (others => '0');
    signal sine_out_150Hz : std_logic_vector(23 downto 0) := (others => '0');
    signal sine_sum : std_logic_vector(23 downto 0) := (others => '0');
    signal rand_out : std_logic_vector(23 downto 0) := (others => '0');

    signal SPF_output : std_logic_vector(23 downto 0) := (others => '0');
    signal AFF_output : std_logic_vector(23 downto 0) := (others => '0');
    signal PPF_output, PPF_negative : std_logic_vector(23 downto 0) := (others => '0');

    signal gnd : std_logic_vector(23 downto 0) := (others => '0');
    signal ctrl : std_logic_vector(31 downto 0);
begin
    
    CONTROL_UNIT : entity work.control_unit
    port map(
        clk_anc => clk_anc,
        reset => reset,
        adapt => adapt,
        ctrl => ctrl
    );
    
    SIGNAL_ROUTING : process(sine_sum, PPF_negative, training_noise, ctrl(0), adapt)
    begin
        if ctrl(0) = '1' then --training_mode = 1
            noise <= (others => '0');
            antiNoise <= training_noise;
        else
            noise <= sine_sum;
            if adapt = '1' then
            antiNoise <= PPF_negative; else
            antiNoise <= (others => '0'); end if;
        end if;
    end process;
    
    refMic <= refMic_in; errMic <= errMic_in;
    noise_out <= noise; antiNoise_out <= antiNoise;
    
    AF_REF_SUM <= std_logic_vector( signed(refMic) - signed(AFF_output) );
    PPF_negative <= std_logic_vector( - signed(PPF_output) );
    
	PRIMARY_SOUND_PATH : entity work.primary_path
	generic map(L => 640, W => 16, leak_en => '1')
	port map(
		clk_anc => clk_anc,
		clk_dsp => clk_dsp,
		clk_ila => clk_ila,
		reset => reset,
		filt_enable => ctrl(6), --PPF_en
		filt_input => AF_REF_SUM,
		filt_output => PPF_output,
		algo_enable => ctrl(7), --PPA_en
		algo_input => SPF_output,
		algo_error => errMic,
		algo_adapt => ctrl(8)--PPA_adapt
	);
	
	SECONDARY_SOUND_PATH : entity work.secondary_path
	generic map(L => 128, W => 8, leak_en => '0')
	port map(
		clk_anc => clk_anc,
		clk_dsp => clk_dsp,
		clk_ila => clk_ila,
		reset => reset,
		algo_enable => ctrl(4), --SPA_en
		algo_input => training_noise,
		algo_desired => errMic,
		algo_adapt => ctrl(5), --SPA_adapt
		filt_enable => ctrl(3), --SPF_en
		filt_input => AF_REF_SUM,
		filt_output => SPF_output
	);
    
	ACOUSTIC_FEEDBACK_SOUND_PATH : entity work.secondary_path
	generic map(L => 128, W => 8, leak_en => '0')
	port map(
		clk_anc => clk_anc,
		clk_dsp => clk_dsp,
		clk_ila => clk_ila,
		reset => reset,
		algo_enable => ctrl(10), --AFA_en
		algo_input => training_noise,
		algo_desired => refMic,
		algo_adapt => ctrl(11), --AFA_adapt
		filt_enable => ctrl(9), --AFF_en
		filt_input => antiNoise,
		filt_output => AFF_output
	);
	
    WHITE_NOISE : entity work.PRBS
    port map(clk => clk_anc, rst => reset, ce => ctrl(2), rand => rand_out);
    training_noise <= std_logic_vector(shift_right(signed(rand_out), 5)); --divide 32x

    SINE_WAVE_225 : entity work.sine_generator(amplitude_15) --225Hz sine output
    port map(clk => clk_22Khz, reset => reset, clk_enable => ctrl(1), Out1 => sine_out_225Hz);
    SINE_WAVE_150 : entity work.sine_generator(amplitude_25) --150Hz sine output, 1K sample period
    port map(clk => clk_41Khz, reset => reset, clk_enable => ctrl(1), Out1 => sine_out_150Hz);
    sine_sum <= std_logic_vector(signed(sine_out_225Hz) + signed(sine_out_150Hz));
    
    CLK_GEN_22Khz : entity work.clk_div --22.5Khz drives 225Hz sine, training noise
    generic map(count => 556) port map(clk_in => clk, clk_out => clk_22Khz);
    CLK_GEN_41Khz : entity work.clk_div --15Khz drives 150Hz sine
    generic map(count => 834) port map(clk_in => clk, clk_out => clk_41Khz);
--    CLK_GEN_ILA : entity work.clk_div --375Khz drives ILA debugger. clock must be >2.5x JTAG clk
--    generic map(count => 334) port map(clk_in => clk, clk_out => clk_ila);
    
--    DEBUG_SIGNALS_1 : ila_3
--    PORT MAP(
--        clk     => clk_ila,
--        probe0  => refMic,
--        probe1  => errMic,
--        probe2  => noise,
--        probe3  => antiNoise,
--        probe4  => trainingNoise, --secondary path filter out
--        probe5  => AFF_output, --acoustic feedback filter out
--        probe6  => PPF_output, --primary path filter out
--        probe7  => gnd,
--        probe8  => SPA_en,
--        probe9  => AFA_en,
--        probe10 => PPA_en,
--        probe11 => SPF_en,
--        probe12 => AFF_en,
--        probe13 => PPF_en,
--        probe14 => trainingMode,
--        probe15 => adapt
--    );
    
end rtl;