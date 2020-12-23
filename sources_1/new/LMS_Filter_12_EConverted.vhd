-- -------------------------------------------------------------
-- 
-- File Name: hdl_prj\hdlsrc\lms_filter\LMS_Filter_24_Subsystem.vhd
-- Created: 2020-10-27 14:05:52
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
-- error_rsvd                    ce_out        0.2
-- weights                       ce_out        0.2
-- -------------------------------------------------------------
-- 
-- -------------------------------------------------------------


-- -------------------------------------------------------------
-- 
-- Module: LMS_Filter_24_Subsystem
-- Source Path: lms_filter/LMS_Filter_24_Subsystem
-- Hierarchy Level: 0
-- 
-- -------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.anc_package.ALL;

ENTITY LMS_Filter_12_EConverted IS
  PORT( clk          :   IN    std_logic;
        reset        :   IN    std_logic;
        clk_enable   :   IN    std_logic;
        input        :   IN    std_logic_vector(23 DOWNTO 0);  -- sfix24_En24
        error      :   IN    std_logic_vector(23 DOWNTO 0);  -- sfix24_En24
        adapt        :   IN    std_logic;
        weights                           :   OUT   vector_of_std_logic_vector24(0 TO 11)  -- sfix24_En24 [12]
        );
END LMS_Filter_12_EConverted;

--
ARCHITECTURE rtl OF LMS_Filter_12_EConverted IS

  -- Constants
  CONSTANT C_LMS_FILTER_24_STEP_SIZE      : signed(23 DOWNTO 0) := 
    "010000000000000000000000";  -- sfix24_En23

  -- Signals
  SIGNAL enb                              : std_logic;
  SIGNAL input_signed                     : signed(23 DOWNTO 0) := (others => '0');  -- sfix24_En24
  SIGNAL desired_signed                   : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL LMS_Filter_24_out1               : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL LMS_Filter_24_out2               : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL LMS_Filter_24_out3               : vector_of_signed24(0 TO 11):= (others => (others => '0'));  -- sfix24_En24 [12]
  SIGNAL weight                           : vector_of_signed24(0 TO 11):= (others => (others => '0'));  -- sfix24_En24 [12]
  SIGNAL filter_sum                       : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL data_pipeline                    : vector_of_signed24(0 TO 11):= (others => (others => '0'));  -- sfix24_En24 [12]
  SIGNAL data_pipeline_tmp                : vector_of_signed24(0 TO 10):= (others => (others => '0'));  -- sfix24_En24 [11]
  SIGNAL filter_products                  : vector_of_signed24(0 TO 11):= (others => (others => '0'));  -- sfix24_En24 [12]
  SIGNAL mul_temp                         : signed(47 DOWNTO 0):= (others => '0');  -- sfix48_En48
  SIGNAL mul_temp_1                       : signed(47 DOWNTO 0):= (others => '0');  -- sfix48_En48
  SIGNAL mul_temp_2                       : signed(47 DOWNTO 0):= (others => '0');  -- sfix48_En48
  SIGNAL mul_temp_3                       : signed(47 DOWNTO 0):= (others => '0');  -- sfix48_En48
  SIGNAL mul_temp_4                       : signed(47 DOWNTO 0):= (others => '0');  -- sfix48_En48
  SIGNAL mul_temp_5                       : signed(47 DOWNTO 0):= (others => '0');  -- sfix48_En48
  SIGNAL mul_temp_6                       : signed(47 DOWNTO 0):= (others => '0');  -- sfix48_En48
  SIGNAL mul_temp_7                       : signed(47 DOWNTO 0):= (others => '0');  -- sfix48_En48
  SIGNAL mul_temp_8                       : signed(47 DOWNTO 0):= (others => '0');  -- sfix48_En48
  SIGNAL mul_temp_9                       : signed(47 DOWNTO 0):= (others => '0');  -- sfix48_En48
  SIGNAL mul_temp_10                      : signed(47 DOWNTO 0):= (others => '0');  -- sfix48_En48
  SIGNAL mul_temp_11                      : signed(47 DOWNTO 0):= (others => '0');  -- sfix48_En48
  SIGNAL sum_1                            : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_cast                         : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_cast_1                       : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_temp                         : signed(24 DOWNTO 0):= (others => '0');  -- sfix25_En24
  SIGNAL sum_2                            : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_cast_2                       : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_cast_3                       : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_temp_1                       : signed(24 DOWNTO 0):= (others => '0');  -- sfix25_En24
  SIGNAL sum_3                            : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_cast_4                       : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_cast_5                       : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_temp_2                       : signed(24 DOWNTO 0):= (others => '0');  -- sfix25_En24
  SIGNAL sum_4                            : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_cast_6                       : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_cast_7                       : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_temp_3                       : signed(24 DOWNTO 0):= (others => '0');  -- sfix25_En24
  SIGNAL sum_5                            : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_cast_8                       : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_cast_9                       : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_temp_4                       : signed(24 DOWNTO 0):= (others => '0');  -- sfix25_En24
  SIGNAL sum_6                            : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_cast_10                      : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_cast_11                      : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_temp_5                       : signed(24 DOWNTO 0):= (others => '0');  -- sfix25_En24
  SIGNAL sum_7                            : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_cast_12                      : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_cast_13                      : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_temp_6                       : signed(24 DOWNTO 0):= (others => '0');  -- sfix25_En24
  SIGNAL sum_8                            : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_cast_14                      : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_cast_15                      : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_temp_7                       : signed(24 DOWNTO 0):= (others => '0');  -- sfix25_En24
  SIGNAL sum_9                            : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_cast_16                      : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_cast_17                      : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_temp_8                       : signed(24 DOWNTO 0):= (others => '0');  -- sfix25_En24
  SIGNAL sum_10                           : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_cast_18                      : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_cast_19                      : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_temp_9                       : signed(24 DOWNTO 0):= (others => '0');  -- sfix25_En24
  SIGNAL add_cast_20                      : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_cast_21                      : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_temp_10                      : signed(24 DOWNTO 0):= (others => '0');  -- sfix25_En24
  SIGNAL sub_cast                         : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL sub_cast_1                       : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL sub_temp                         : signed(24 DOWNTO 0):= (others => '0');  -- sfix25_En24
  SIGNAL mu_err                           : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL mul_temp_12                      : signed(47 DOWNTO 0):= (others => '0');  -- sfix48_En47
  SIGNAL mu_err_data_prod                 : vector_of_signed24(0 TO 11):= (others => (others => '0'));  -- sfix24_En24 [12]
  SIGNAL mul_temp_13                      : signed(47 DOWNTO 0):= (others => '0');  -- sfix48_En48
  SIGNAL mul_temp_14                      : signed(47 DOWNTO 0):= (others => '0');  -- sfix48_En48
  SIGNAL mul_temp_15                      : signed(47 DOWNTO 0):= (others => '0');  -- sfix48_En48
  SIGNAL mul_temp_16                      : signed(47 DOWNTO 0):= (others => '0');  -- sfix48_En48
  SIGNAL mul_temp_17                      : signed(47 DOWNTO 0):= (others => '0');  -- sfix48_En48
  SIGNAL mul_temp_18                      : signed(47 DOWNTO 0):= (others => '0');  -- sfix48_En48
  SIGNAL mul_temp_19                      : signed(47 DOWNTO 0):= (others => '0');  -- sfix48_En48
  SIGNAL mul_temp_20                      : signed(47 DOWNTO 0):= (others => '0');  -- sfix48_En48
  SIGNAL mul_temp_21                      : signed(47 DOWNTO 0):= (others => '0');  -- sfix48_En48
  SIGNAL mul_temp_22                      : signed(47 DOWNTO 0):= (others => '0');  -- sfix48_En48
  SIGNAL mul_temp_23                      : signed(47 DOWNTO 0):= (others => '0');  -- sfix48_En48
  SIGNAL mul_temp_24                      : signed(47 DOWNTO 0):= (others => '0');  -- sfix48_En48
  SIGNAL weight_adder_output              : vector_of_signed24(0 TO 11):= (others => (others => '0'));  -- sfix24_En24 [12]
  SIGNAL add_cast_22                      : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_cast_23                      : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_temp_11                      : signed(24 DOWNTO 0):= (others => '0');  -- sfix25_En24
  SIGNAL add_cast_24                      : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_cast_25                      : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_temp_12                      : signed(24 DOWNTO 0):= (others => '0');  -- sfix25_En24
  SIGNAL add_cast_26                      : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_cast_27                      : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_temp_13                      : signed(24 DOWNTO 0):= (others => '0');  -- sfix25_En24
  SIGNAL add_cast_28                      : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_cast_29                      : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_temp_14                      : signed(24 DOWNTO 0):= (others => '0');  -- sfix25_En24
  SIGNAL add_cast_30                      : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_cast_31                      : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_temp_15                      : signed(24 DOWNTO 0):= (others => '0');  -- sfix25_En24
  SIGNAL add_cast_32                      : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_cast_33                      : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_temp_16                      : signed(24 DOWNTO 0):= (others => '0');  -- sfix25_En24
  SIGNAL add_cast_34                      : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_cast_35                      : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_temp_17                      : signed(24 DOWNTO 0):= (others => '0');  -- sfix25_En24
  SIGNAL add_cast_36                      : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_cast_37                      : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_temp_18                      : signed(24 DOWNTO 0):= (others => '0');  -- sfix25_En24
  SIGNAL add_cast_38                      : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_cast_39                      : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_temp_19                      : signed(24 DOWNTO 0):= (others => '0');  -- sfix25_En24
  SIGNAL add_cast_40                      : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_cast_41                      : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_temp_20                      : signed(24 DOWNTO 0):= (others => '0');  -- sfix25_En24
  SIGNAL add_cast_42                      : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_cast_43                      : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_temp_21                      : signed(24 DOWNTO 0):= (others => '0');  -- sfix25_En24
  SIGNAL add_cast_44                      : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_cast_45                      : signed(23 DOWNTO 0):= (others => '0');  -- sfix24_En24
  SIGNAL add_temp_22                      : signed(24 DOWNTO 0):= (others => '0');  -- sfix25_En24
  SIGNAL weight_backwards                 : vector_of_signed24(0 TO 11):= (others => (others => '0'));  -- sfix24_En24 [12]
    
    signal error_signed : signed(23 downto 0);
BEGIN
  input_signed <= signed(input);

  error_signed <= signed(error);

  enb <= clk_enable;


-- ***********************
-- ********* LMS *********
-- ***********************

-- * LMS: FIR section

  LMS_Filter_12_del_temp_process1 : PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF reset = '1' THEN
        data_pipeline_tmp <= (OTHERS => (OTHERS => '0'));
      ELSIF enb = '1' THEN
        data_pipeline_tmp(0 TO 9) <= data_pipeline_tmp(1 TO 10);
        data_pipeline_tmp(10) <= input_signed;
      END IF;
    END IF;
  END PROCESS LMS_Filter_12_del_temp_process1;

  data_pipeline(0 TO 10) <= data_pipeline_tmp(0 TO 10);
  data_pipeline(11) <= input_signed;

-- ***** LMS Weight Update Function *****

  mul_temp_12 <= C_LMS_FILTER_24_STEP_SIZE * error_signed;
  mu_err <= mul_temp_12(47 DOWNTO 24);

  mul_temp_13 <= data_pipeline(0) * mu_err;
  mu_err_data_prod(0) <= mul_temp_13(47 DOWNTO 24);

  mul_temp_14 <= data_pipeline(1) * mu_err;
  mu_err_data_prod(1) <= mul_temp_14(47 DOWNTO 24);

  mul_temp_15 <= data_pipeline(2) * mu_err;
  mu_err_data_prod(2) <= mul_temp_15(47 DOWNTO 24);

  mul_temp_16 <= data_pipeline(3) * mu_err;
  mu_err_data_prod(3) <= mul_temp_16(47 DOWNTO 24);

  mul_temp_17 <= data_pipeline(4) * mu_err;
  mu_err_data_prod(4) <= mul_temp_17(47 DOWNTO 24);

  mul_temp_18 <= data_pipeline(5) * mu_err;
  mu_err_data_prod(5) <= mul_temp_18(47 DOWNTO 24);

  mul_temp_19 <= data_pipeline(6) * mu_err;
  mu_err_data_prod(6) <= mul_temp_19(47 DOWNTO 24);

  mul_temp_20 <= data_pipeline(7) * mu_err;
  mu_err_data_prod(7) <= mul_temp_20(47 DOWNTO 24);

  mul_temp_21 <= data_pipeline(8) * mu_err;
  mu_err_data_prod(8) <= mul_temp_21(47 DOWNTO 24);

  mul_temp_22 <= data_pipeline(9) * mu_err;
  mu_err_data_prod(9) <= mul_temp_22(47 DOWNTO 24);

  mul_temp_23 <= data_pipeline(10) * mu_err;
  mu_err_data_prod(10) <= mul_temp_23(47 DOWNTO 24);

  mul_temp_24 <= data_pipeline(11) * mu_err;
  mu_err_data_prod(11) <= mul_temp_24(47 DOWNTO 24);

-- * LMS_Filter_24 Weight Accumulator

  add_cast_22 <= weight(0);
  add_cast_23 <= mu_err_data_prod(0);
  add_temp_11 <= resize(add_cast_22, 25) + resize(add_cast_23, 25);
  weight_adder_output(0) <= add_temp_11(23 DOWNTO 0);

  add_cast_24 <= weight(1);
  add_cast_25 <= mu_err_data_prod(1);
  add_temp_12 <= resize(add_cast_24, 25) + resize(add_cast_25, 25);
  weight_adder_output(1) <= add_temp_12(23 DOWNTO 0);

  add_cast_26 <= weight(2);
  add_cast_27 <= mu_err_data_prod(2);
  add_temp_13 <= resize(add_cast_26, 25) + resize(add_cast_27, 25);
  weight_adder_output(2) <= add_temp_13(23 DOWNTO 0);

  add_cast_28 <= weight(3);
  add_cast_29 <= mu_err_data_prod(3);
  add_temp_14 <= resize(add_cast_28, 25) + resize(add_cast_29, 25);
  weight_adder_output(3) <= add_temp_14(23 DOWNTO 0);

  add_cast_30 <= weight(4);
  add_cast_31 <= mu_err_data_prod(4);
  add_temp_15 <= resize(add_cast_30, 25) + resize(add_cast_31, 25);
  weight_adder_output(4) <= add_temp_15(23 DOWNTO 0);

  add_cast_32 <= weight(5);
  add_cast_33 <= mu_err_data_prod(5);
  add_temp_16 <= resize(add_cast_32, 25) + resize(add_cast_33, 25);
  weight_adder_output(5) <= add_temp_16(23 DOWNTO 0);

  add_cast_34 <= weight(6);
  add_cast_35 <= mu_err_data_prod(6);
  add_temp_17 <= resize(add_cast_34, 25) + resize(add_cast_35, 25);
  weight_adder_output(6) <= add_temp_17(23 DOWNTO 0);

  add_cast_36 <= weight(7);
  add_cast_37 <= mu_err_data_prod(7);
  add_temp_18 <= resize(add_cast_36, 25) + resize(add_cast_37, 25);
  weight_adder_output(7) <= add_temp_18(23 DOWNTO 0);

  add_cast_38 <= weight(8);
  add_cast_39 <= mu_err_data_prod(8);
  add_temp_19 <= resize(add_cast_38, 25) + resize(add_cast_39, 25);
  weight_adder_output(8) <= add_temp_19(23 DOWNTO 0);

  add_cast_40 <= weight(9);
  add_cast_41 <= mu_err_data_prod(9);
  add_temp_20 <= resize(add_cast_40, 25) + resize(add_cast_41, 25);
  weight_adder_output(9) <= add_temp_20(23 DOWNTO 0);

  add_cast_42 <= weight(10);
  add_cast_43 <= mu_err_data_prod(10);
  add_temp_21 <= resize(add_cast_42, 25) + resize(add_cast_43, 25);
  weight_adder_output(10) <= add_temp_21(23 DOWNTO 0);

  add_cast_44 <= weight(11);
  add_cast_45 <= mu_err_data_prod(11);
  add_temp_22 <= resize(add_cast_44, 25) + resize(add_cast_45, 25);
  weight_adder_output(11) <= add_temp_22(23 DOWNTO 0);

    LMS_Filter_12_acc_temp_process2 : PROCESS (clk)
    BEGIN
        IF clk'event AND clk = '1' THEN
            IF reset = '1' THEN
                weight <= (OTHERS => (OTHERS => '0'));
            ELSIF enb = '1' AND adapt = '1' THEN
                weight(0 TO 11) <= weight_adder_output(0 TO 11);
            END IF;
        END IF;
    END PROCESS LMS_Filter_12_acc_temp_process2;

-- * LMS_Filter_24 Weight Output Port

  weight_backwards <= weight_adder_output WHEN ( adapt = '1' ) ELSE
                      weight;
  LMS_Filter_24_out3(11) <= weight_backwards(0);
  LMS_Filter_24_out3(10) <= weight_backwards(1);
  LMS_Filter_24_out3(9) <= weight_backwards(2);
  LMS_Filter_24_out3(8) <= weight_backwards(3);
  LMS_Filter_24_out3(7) <= weight_backwards(4);
  LMS_Filter_24_out3(6) <= weight_backwards(5);
  LMS_Filter_24_out3(5) <= weight_backwards(6);
  LMS_Filter_24_out3(4) <= weight_backwards(7);
  LMS_Filter_24_out3(3) <= weight_backwards(8);
  LMS_Filter_24_out3(2) <= weight_backwards(9);
  LMS_Filter_24_out3(1) <= weight_backwards(10);
  LMS_Filter_24_out3(0) <= weight_backwards(11);


--  output <= std_logic_vector(LMS_Filter_24_out1);

--  error_rsvd <= std_logic_vector(LMS_Filter_24_out2);

  outputgen: FOR k IN 0 TO 11 GENERATE
    weights(k) <= std_logic_vector(LMS_Filter_24_out3(k));
  END GENERATE;

--  ce_out <= clk_enable;

END rtl;

