----------------------------------------------------------------------------------
-- Company: 
-- Engineers: Brian Cheng, Prashant Baliga
-- 
-- Create Date: 10/17/2020 10:59:32 PM
-- Design Name: 
-- Module Name: top_level - rtl
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

entity top_level is
    port(
        --fpga
        clk : in std_logic;
        btn0, btn1, btn2, btn3  : in std_logic;
        sw0, sw1 : in std_logic;
        
        referenceMic : in std_logic_vector(23 downto 0);
        errorMic : in std_logic_vector(23 downto 0);
        antiNoise : out std_logic_vector(23 downto 0)
        
        --pmod_i2s2
--        tx_mclk : out std_logic;
--        tx_lrck : out std_logic;
--		tx_sclk : out std_logic;
--		tx_data : out std_logic;
--		rx_mclk : out std_logic;
--		rx_lrck : out std_logic;
--		rx_sclk : out std_logic;
--		rx_data : in std_logic   
    );
end top_level;

architecture rtl of top_level is
    signal reset : std_logic;
    signal refMic : std_logic_vector(23 downto 0);
    signal errMic : std_logic_vector(23 downto 0);
    
    signal sum1_out : std_logic_vector(23 downto 0);
    
    signal adapt, enable, trainingMode : std_logic;

    signal Wanc : vector_of_std_logic_vector24(0 TO 11);
    signal Wsp : vector_of_std_logic_vector24(0 TO 11);
    signal Waf : vector_of_std_logic_vector24(0 TO 11);
    
    signal nlms_adapt, nlms_ce_out, nlms_clk_en : std_logic;
    signal SP_en, SP_validIn, SP_validOut : std_logic;
    signal SP_FilterOut : std_logic_vector(23 downto 0);

    signal ANC_en, ANC_validIn, ANC_validOut : std_logic;
    signal ANC_FilterOut, ANC_FilterOut_Negative : std_logic_vector(23 downto 0);
    
    signal AF_en, AF_ValidIn, AF_validOut : std_logic;
    signal AF_FilterOut : std_logic_vector(23 downto 0);
    
    signal AntiNoiseAdapt, AntiNoiseAdaptDelayed: std_logic_vector(23 downto 0);
    
    signal SPE_clkEnable, SPE_ce_out : std_logic;
    signal AFE_clkEnable, AFE_ce_out : std_logic;
    
    signal trainingNoise : std_logic_vector(23 downto 0) := X"123456";
begin
    
    refMic <= referenceMic;
    errMic <= errorMic;
    antiNoise <= AntiNoiseAdapt;
    
    adapt <= sw0;
    trainingMode <= sw1;
    enable <= btn1;
    
    sum1_out <= std_logic_vector( signed(refMic) - signed(AF_FilterOut) );
    
    reset <= btn0;
    
    ANC_FilterOut_Negative <= std_logic_vector(-signed(ANC_FilterOut));
    with enable select AntiNoiseAdapt <= (others => '0') when '0', ANC_FilterOut_Negative when '1';
    
    ANTINOISE_REGISTER : process(clk)
    begin
        if rising_edge(clk) then
            AntiNoiseAdaptDelayed <= AntiNoiseAdapt;
        end if;
    end process;
    
    SP_ValidIn <= '1'; SP_en <= '1';
    SECONDARY_PATH_FILER : entity work.Discrete_FIR_Filter_HDL_Optimized
    port map(
        clk => clk,
        reset => reset,
        enb => SP_en,
        dataIn => sum1_out,
        validIn => SP_ValidIn,
        Coeff => Wsp,
        dataOut => SP_FilterOut,
        validOut => SP_validOut
    );
    
    ANC_en <= '1'; ANC_validIn <= '1';
    ANC_FILTER : entity work.Discrete_FIR_Filter_HDL_Optimized
    port map(
        clk => clk,
        reset => reset,
        enb => ANC_en,
        dataIn => sum1_out,
        validIn => ANC_validIn,
        Coeff => Wanc,
        dataOut => ANC_FilterOut,
        validOut => ANC_validOut
    );
    
    AF_en <= '1'; AF_validIn <= '1';
    ACOUSTIC_FEEDBACK_FILTER : entity work.Discrete_FIR_Filter_HDL_Optimized
    port map(
        clk => clk,
        reset => reset,
        enb => AF_en,
        dataIn => AntiNoiseAdaptDelayed,
        validIn => AF_validIn,
        Coeff => Waf,
        dataOut => AF_FilterOut,
        validOut => AF_validOut        
    );
    
    nlms_adapt <= (NOT trainingMode) AND enable;
    nlms_clk_en <= '1';
    NLMS_UPDATE : entity work.nlmsUpdateSystem
    port map(
        clk => clk,
        reset => reset,
        clk_enable => nlms_clk_en,
        input => SP_FilterOut,
        error_rsvd => errMic,
        adapt => nlms_adapt,
        ce_out => nlms_ce_out,
        weights => Wanc
    );
    
    SPE_clkEnable <= '1';
    SECONDARY_PATH_ESTIMATION : entity work.LMSFilter
    port map(
        clk => clk,
        reset => reset,
        clk_enable => SPE_clkEnable,
        In1 => trainingNoise,
        In2 => errMic,
        ce_out => SPE_ce_out,
        Out3 => Wsp
    );
    
    AFE_clkEnable <= '1';
    ACOUSTIC_FEEDBACK_ESTIMATION : entity work.LMSFilter
    port map(
        clk => clk,
        reset => reset,
        clk_enable => AFE_clkEnable,
        In1 => trainingNoise,
        In2 => refMic,
        ce_out => AFE_ce_out,
        Out3 => Waf
    );
    
end rtl;
