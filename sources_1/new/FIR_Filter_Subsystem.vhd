-- -------------------------------------------------------------
-- 
-- File Name: hdl_prj\hdlsrc\fir_filter2\FIR_Filter_Subsystem.vhd
-- Created: 2020-10-23 15:41:08
-- 
-- Generated by MATLAB 9.7 and HDL Coder 3.15
-- 
-- 
-- -------------------------------------------------------------
-- Rate and Clocking Details
-- -------------------------------------------------------------
-- Model base rate: 0.2
-- Target subsystem base rate: 0.2
-- 
-- 
-- Clock Enable  Sample Time
-- -------------------------------------------------------------
-- ce_out        0.2
-- -------------------------------------------------------------
-- 
-- 
-- Output Signal                 Clock Enable  Sample Time
-- -------------------------------------------------------------
-- output                        ce_out        0.2
-- -------------------------------------------------------------
-- 
-- -------------------------------------------------------------


-- -------------------------------------------------------------
-- 
-- Module: FIR_Filter_Subsystem
-- Source Path: fir_filter2/FIR Filter Subsystem
-- Hierarchy Level: 0
-- 
-- -------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.top_level_pkg.ALL;--

ENTITY FIR_Filter_Subsystem IS
  PORT( clk                               :   IN    std_logic;
        reset                             :   IN    std_logic;
        clk_enable                        :   IN    std_logic;
        input                             :   IN    std_logic_vector(23 DOWNTO 0);  -- sfix24
        coeff                             :   IN    vector_of_std_logic_vector24(0 TO 11);  -- sfix24_En23 [12]
        ce_out                            :   OUT   std_logic;
        output                            :   OUT   std_logic_vector(23 DOWNTO 0)  -- sfix24
        );
END FIR_Filter_Subsystem;


ARCHITECTURE rtl OF FIR_Filter_Subsystem IS

  -- Component Declarations
  COMPONENT Discrete_FIR_Filter
    PORT( clk                             :   IN    std_logic;
          reset                           :   IN    std_logic;
          enb_const_rate                  :   IN    std_logic;
          Discrete_FIR_Filter_in          :   IN    std_logic_vector(23 DOWNTO 0);  -- sfix24
          Discrete_FIR_Filter_coeff       :   IN    vector_of_std_logic_vector24(0 TO 11);  -- sfix24_En23 [12]
          Discrete_FIR_Filter_out         :   OUT   std_logic_vector(23 DOWNTO 0)  -- sfix24
          );
  END COMPONENT;

  -- Component Configuration Statements
  FOR ALL : Discrete_FIR_Filter
    USE ENTITY work.Discrete_FIR_Filter(rtl);

  -- Signals
  SIGNAL Discrete_FIR_Filter_out1         : std_logic_vector(23 DOWNTO 0);  -- ufix24

BEGIN
  u_Discrete_FIR_Filter : Discrete_FIR_Filter
    PORT MAP( clk => clk,
              reset => reset,
              enb_const_rate => clk_enable,
              Discrete_FIR_Filter_in => input,  -- sfix24
              Discrete_FIR_Filter_coeff => coeff,  -- sfix24_En23 [12]
              Discrete_FIR_Filter_out => Discrete_FIR_Filter_out1  -- sfix24
              );

  ce_out <= clk_enable;

  output <= Discrete_FIR_Filter_out1;

END rtl;

