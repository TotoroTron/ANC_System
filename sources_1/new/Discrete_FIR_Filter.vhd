-- -------------------------------------------------------------
-- 
-- File Name: hdl_prj\hdlsrc\fir_filter2\Discrete_FIR_Filter.vhd
-- Created: 2020-10-23 15:41:08
-- 
-- Generated by MATLAB 9.7 and HDL Coder 3.15
-- 
-- -------------------------------------------------------------


-- -------------------------------------------------------------
-- 
-- Module: Discrete_FIR_Filter
-- Source Path: fir_filter2/FIR Filter Subsystem/Discrete FIR Filter
-- Hierarchy Level: 1
-- 
-- -------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.top_level_pkg.ALL;--

ENTITY Discrete_FIR_Filter IS
  PORT( clk                               :   IN    std_logic;
        reset                             :   IN    std_logic;
        enb_const_rate                    :   IN    std_logic;
        Discrete_FIR_Filter_in            :   IN    std_logic_vector(23 DOWNTO 0);  -- sfix24
        Discrete_FIR_Filter_coeff         :   IN    vector_of_std_logic_vector24(0 TO 11);  -- sfix24_En23 [12]
        Discrete_FIR_Filter_out           :   OUT   std_logic_vector(23 DOWNTO 0)  -- sfix24
        );
END Discrete_FIR_Filter;


ARCHITECTURE rtl OF Discrete_FIR_Filter IS

  -- Signals
  SIGNAL Discrete_FIR_Filter_in_signed    : signed(23 DOWNTO 0) := (others => '0');  -- sfix24
  SIGNAL Discrete_FIR_Filter_coeff_0      : signed(23 DOWNTO 0) := (others => '0');  -- sfix24_En23
  SIGNAL delay_pipeline_1                 : vector_of_signed24(0 TO 10) := (others => (others => '0'));  -- sfix24 [11]
  SIGNAL product1                         : signed(47 DOWNTO 0) := (others => '0');  -- sfix48_En23
  SIGNAL delay_pipeline_0                 : signed(23 DOWNTO 0) := (others => '0');  -- sfix24
  SIGNAL Discrete_FIR_Filter_coeff_1      : signed(23 DOWNTO 0) := (others => '0');  -- sfix24_En23
  SIGNAL product2                         : signed(47 DOWNTO 0) := (others => '0');  -- sfix48_En23
  SIGNAL adder_add_cast                   : signed(51 DOWNTO 0) := (others => '0');  -- sfix52_En23
  SIGNAL adder_add_cast_1                 : signed(51 DOWNTO 0) := (others => '0');  -- sfix52_En23
  SIGNAL sum1                             : signed(51 DOWNTO 0) := (others => '0');  -- sfix52_En23
  SIGNAL delay_pipeline_1_1               : signed(23 DOWNTO 0) := (others => '0');  -- sfix24
  SIGNAL Discrete_FIR_Filter_coeff_2      : signed(23 DOWNTO 0) := (others => '0');  -- sfix24_En23
  SIGNAL product3                         : signed(47 DOWNTO 0) := (others => '0');  -- sfix48_En23
  SIGNAL adder_add_cast_2                 : signed(51 DOWNTO 0) := (others => '0');  -- sfix52_En23
  SIGNAL sum2                             : signed(51 DOWNTO 0) := (others => '0');  -- sfix52_En23
  SIGNAL delay_pipeline_2                 : signed(23 DOWNTO 0) := (others => '0');  -- sfix24
  SIGNAL Discrete_FIR_Filter_coeff_3      : signed(23 DOWNTO 0) := (others => '0');  -- sfix24_En23
  SIGNAL product4                         : signed(47 DOWNTO 0) := (others => '0');  -- sfix48_En23
  SIGNAL adder_add_cast_3                 : signed(51 DOWNTO 0) := (others => '0');  -- sfix52_En23
  SIGNAL sum3                             : signed(51 DOWNTO 0) := (others => '0');  -- sfix52_En23
  SIGNAL delay_pipeline_3                 : signed(23 DOWNTO 0) := (others => '0');  -- sfix24
  SIGNAL Discrete_FIR_Filter_coeff_4      : signed(23 DOWNTO 0) := (others => '0');  -- sfix24_En23
  SIGNAL product5                         : signed(47 DOWNTO 0) := (others => '0');  -- sfix48_En23
  SIGNAL adder_add_cast_4                 : signed(51 DOWNTO 0) := (others => '0');  -- sfix52_En23
  SIGNAL sum4                             : signed(51 DOWNTO 0) := (others => '0');  -- sfix52_En23
  SIGNAL delay_pipeline_4                 : signed(23 DOWNTO 0) := (others => '0');  -- sfix24
  SIGNAL Discrete_FIR_Filter_coeff_5      : signed(23 DOWNTO 0) := (others => '0');  -- sfix24_En23
  SIGNAL product6                         : signed(47 DOWNTO 0) := (others => '0');  -- sfix48_En23
  SIGNAL adder_add_cast_5                 : signed(51 DOWNTO 0) := (others => '0');  -- sfix52_En23
  SIGNAL sum5                             : signed(51 DOWNTO 0) := (others => '0');  -- sfix52_En23
  SIGNAL delay_pipeline_5                 : signed(23 DOWNTO 0) := (others => '0');  -- sfix24
  SIGNAL Discrete_FIR_Filter_coeff_6      : signed(23 DOWNTO 0) := (others => '0');  -- sfix24_En23
  SIGNAL product7                         : signed(47 DOWNTO 0) := (others => '0');  -- sfix48_En23
  SIGNAL adder_add_cast_6                 : signed(51 DOWNTO 0) := (others => '0');  -- sfix52_En23
  SIGNAL sum6                             : signed(51 DOWNTO 0) := (others => '0');  -- sfix52_En23
  SIGNAL delay_pipeline_6                 : signed(23 DOWNTO 0) := (others => '0');  -- sfix24
  SIGNAL Discrete_FIR_Filter_coeff_7      : signed(23 DOWNTO 0) := (others => '0');  -- sfix24_En23
  SIGNAL product8                         : signed(47 DOWNTO 0) := (others => '0');  -- sfix48_En23
  SIGNAL adder_add_cast_7                 : signed(51 DOWNTO 0) := (others => '0');  -- sfix52_En23
  SIGNAL sum7                             : signed(51 DOWNTO 0) := (others => '0');  -- sfix52_En23
  SIGNAL delay_pipeline_7                 : signed(23 DOWNTO 0) := (others => '0');  -- sfix24
  SIGNAL Discrete_FIR_Filter_coeff_8      : signed(23 DOWNTO 0) := (others => '0');  -- sfix24_En23
  SIGNAL product9                         : signed(47 DOWNTO 0) := (others => '0');  -- sfix48_En23
  SIGNAL adder_add_cast_8                 : signed(51 DOWNTO 0) := (others => '0');  -- sfix52_En23
  SIGNAL sum8                             : signed(51 DOWNTO 0) := (others => '0');  -- sfix52_En23
  SIGNAL delay_pipeline_8                 : signed(23 DOWNTO 0) := (others => '0');  -- sfix24
  SIGNAL Discrete_FIR_Filter_coeff_9      : signed(23 DOWNTO 0) := (others => '0');  -- sfix24_En23
  SIGNAL product10                        : signed(47 DOWNTO 0) := (others => '0');  -- sfix48_En23
  SIGNAL adder_add_cast_9                 : signed(51 DOWNTO 0) := (others => '0');  -- sfix52_En23
  SIGNAL sum9                             : signed(51 DOWNTO 0) := (others => '0');  -- sfix52_En23
  SIGNAL delay_pipeline_9                 : signed(23 DOWNTO 0) := (others => '0');  -- sfix24
  SIGNAL Discrete_FIR_Filter_coeff_10     : signed(23 DOWNTO 0) := (others => '0');  -- sfix24_En23
  SIGNAL product11                        : signed(47 DOWNTO 0) := (others => '0');  -- sfix48_En23
  SIGNAL adder_add_cast_10                : signed(51 DOWNTO 0) := (others => '0');  -- sfix52_En23
  SIGNAL sum10                            : signed(51 DOWNTO 0) := (others => '0');  -- sfix52_En23
  SIGNAL delay_pipeline_10                : signed(23 DOWNTO 0) := (others => '0');  -- sfix24
  SIGNAL Discrete_FIR_Filter_coeff_11     : signed(23 DOWNTO 0) := (others => '0');  -- sfix24_En23
  SIGNAL product12                        : signed(47 DOWNTO 0) := (others => '0');  -- sfix48_En23
  SIGNAL adder_add_cast_11                : signed(51 DOWNTO 0) := (others => '0');  -- sfix52_En23
  SIGNAL sum11                            : signed(51 DOWNTO 0) := (others => '0');  -- sfix52_En23
  SIGNAL output_typeconvert               : signed(23 DOWNTO 0) := (others => '0');  -- sfix24

BEGIN
  Discrete_FIR_Filter_in_signed <= signed(Discrete_FIR_Filter_in);

  Discrete_FIR_Filter_coeff_0 <= signed(Discrete_FIR_Filter_coeff(0));

  Delay_Pipeline_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      delay_pipeline_1 <= (OTHERS => to_signed(16#000000#, 24));
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb_const_rate = '1' THEN
        delay_pipeline_1(0) <= Discrete_FIR_Filter_in_signed;
        delay_pipeline_1(1 TO 10) <= delay_pipeline_1(0 TO 9);
      END IF;
    END IF;
  END PROCESS Delay_Pipeline_process;


  product1 <= Discrete_FIR_Filter_in_signed * Discrete_FIR_Filter_coeff_0;

  delay_pipeline_0 <= delay_pipeline_1(0);

  Discrete_FIR_Filter_coeff_1 <= signed(Discrete_FIR_Filter_coeff(1));

  product2 <= delay_pipeline_0 * Discrete_FIR_Filter_coeff_1;

  adder_add_cast <= resize(product1, 52);
  adder_add_cast_1 <= resize(product2, 52);
  sum1 <= adder_add_cast + adder_add_cast_1;

  delay_pipeline_1_1 <= delay_pipeline_1(1);

  Discrete_FIR_Filter_coeff_2 <= signed(Discrete_FIR_Filter_coeff(2));

  product3 <= delay_pipeline_1_1 * Discrete_FIR_Filter_coeff_2;

  adder_add_cast_2 <= resize(product3, 52);
  sum2 <= sum1 + adder_add_cast_2;

  delay_pipeline_2 <= delay_pipeline_1(2);

  Discrete_FIR_Filter_coeff_3 <= signed(Discrete_FIR_Filter_coeff(3));

  product4 <= delay_pipeline_2 * Discrete_FIR_Filter_coeff_3;

  adder_add_cast_3 <= resize(product4, 52);
  sum3 <= sum2 + adder_add_cast_3;

  delay_pipeline_3 <= delay_pipeline_1(3);

  Discrete_FIR_Filter_coeff_4 <= signed(Discrete_FIR_Filter_coeff(4));

  product5 <= delay_pipeline_3 * Discrete_FIR_Filter_coeff_4;

  adder_add_cast_4 <= resize(product5, 52);
  sum4 <= sum3 + adder_add_cast_4;

  delay_pipeline_4 <= delay_pipeline_1(4);

  Discrete_FIR_Filter_coeff_5 <= signed(Discrete_FIR_Filter_coeff(5));

  product6 <= delay_pipeline_4 * Discrete_FIR_Filter_coeff_5;

  adder_add_cast_5 <= resize(product6, 52);
  sum5 <= sum4 + adder_add_cast_5;

  delay_pipeline_5 <= delay_pipeline_1(5);

  Discrete_FIR_Filter_coeff_6 <= signed(Discrete_FIR_Filter_coeff(6));

  product7 <= delay_pipeline_5 * Discrete_FIR_Filter_coeff_6;

  adder_add_cast_6 <= resize(product7, 52);
  sum6 <= sum5 + adder_add_cast_6;

  delay_pipeline_6 <= delay_pipeline_1(6);

  Discrete_FIR_Filter_coeff_7 <= signed(Discrete_FIR_Filter_coeff(7));

  product8 <= delay_pipeline_6 * Discrete_FIR_Filter_coeff_7;

  adder_add_cast_7 <= resize(product8, 52);
  sum7 <= sum6 + adder_add_cast_7;

  delay_pipeline_7 <= delay_pipeline_1(7);

  Discrete_FIR_Filter_coeff_8 <= signed(Discrete_FIR_Filter_coeff(8));

  product9 <= delay_pipeline_7 * Discrete_FIR_Filter_coeff_8;

  adder_add_cast_8 <= resize(product9, 52);
  sum8 <= sum7 + adder_add_cast_8;

  delay_pipeline_8 <= delay_pipeline_1(8);

  Discrete_FIR_Filter_coeff_9 <= signed(Discrete_FIR_Filter_coeff(9));

  product10 <= delay_pipeline_8 * Discrete_FIR_Filter_coeff_9;

  adder_add_cast_9 <= resize(product10, 52);
  sum9 <= sum8 + adder_add_cast_9;

  delay_pipeline_9 <= delay_pipeline_1(9);

  Discrete_FIR_Filter_coeff_10 <= signed(Discrete_FIR_Filter_coeff(10));

  product11 <= delay_pipeline_9 * Discrete_FIR_Filter_coeff_10;

  adder_add_cast_10 <= resize(product11, 52);
  sum10 <= sum9 + adder_add_cast_10;

  delay_pipeline_10 <= delay_pipeline_1(10);

  Discrete_FIR_Filter_coeff_11 <= signed(Discrete_FIR_Filter_coeff(11));

  product12 <= delay_pipeline_10 * Discrete_FIR_Filter_coeff_11;

  adder_add_cast_11 <= resize(product12, 52);
  sum11 <= sum10 + adder_add_cast_11;

  output_typeconvert <= sum11(46 DOWNTO 23);

  Discrete_FIR_Filter_out <= std_logic_vector(output_typeconvert);

END rtl;

