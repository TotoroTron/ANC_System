-- -------------------------------------------------------------
-- 
-- File Name: hdl_prj\hdlsrc\LMSUpdateTester\LMS_Update_24.vhd
-- Created: 2020-11-22 00:55:11
-- 
-- Generated by MATLAB 9.7 and HDL Coder 3.15
-- 
-- -------------------------------------------------------------


-- -------------------------------------------------------------
-- 
-- Module: LMS_Update_24
-- Source Path: LMSUpdateTester/LMSUpdateSystem/LMS_Update_24
-- Hierarchy Level: 1
-- 
-- -------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.top_level_pkg.ALL;

ENTITY LMS_Update_24 IS
  PORT( clk                               :   IN    std_logic;
        reset                             :   IN    std_logic;
        enb                               :   IN    std_logic;
        X                                 :   IN    std_logic_vector(23 DOWNTO 0);  -- sfix24_En24
        E                                 :   IN    std_logic_vector(23 DOWNTO 0);  -- sfix24_En24
        Adapt                             :   IN    std_logic;
        W                                 :   OUT   vector_of_std_logic_vector24(0 TO 23)  -- sfix24_En24 [24]
        );
END LMS_Update_24;


ARCHITECTURE rtl OF LMS_Update_24 IS

  -- Signals
  SIGNAL X_signed                         : signed(23 DOWNTO 0);  -- sfix24_En24
  SIGNAL E_signed                         : signed(23 DOWNTO 0);  -- sfix24_En24
  SIGNAL W_tmp                            : vector_of_signed24(0 TO 23);  -- sfix24_En24 [24]
  SIGNAL xBuffer                          : vector_of_signed24(0 TO 23);  -- sfix24 [24]
  SIGNAL wBuffer                          : vector_of_signed24(0 TO 23);  -- sfix24 [24]
  SIGNAL xBuffer_next                     : vector_of_signed24(0 TO 23);  -- sfix24_En24 [24]
  SIGNAL wBuffer_next                     : vector_of_signed24(0 TO 23);  -- sfix24_En24 [24]

BEGIN
  X_signed <= signed(X);

  E_signed <= signed(E);

    LMS_Update_24_1_process : PROCESS (clk)
    BEGIN
    
    IF clk'EVENT AND clk = '1' THEN
        IF reset = '1' THEN
            xBuffer <= (OTHERS => to_signed(16#000000#, 24));
            wBuffer <= (OTHERS => to_signed(16#000000#, 24));
        ELSIF enb = '1' THEN
            xBuffer <= xBuffer_next;
            wBuffer <= wBuffer_next;
        END IF;
    END IF;
    END PROCESS LMS_Update_24_1_process;

  LMS_Update_24_1_output : PROCESS (Adapt, E_signed, X_signed, wBuffer, xBuffer)
    VARIABLE mu_err : signed(47 DOWNTO 0);
    VARIABLE xBuffer_temp : vector_of_signed24(0 TO 23);
    VARIABLE wBuffer_temp : vector_of_signed24(0 TO 23);
    VARIABLE add_cast : signed(72 DOWNTO 0);
    VARIABLE mul_temp : signed(71 DOWNTO 0);
    VARIABLE add_cast_0 : signed(72 DOWNTO 0);
    VARIABLE add_temp : signed(72 DOWNTO 0);
    VARIABLE add_cast_1 : signed(72 DOWNTO 0);
    VARIABLE mul_temp_0 : signed(71 DOWNTO 0);
    VARIABLE add_cast_2 : signed(72 DOWNTO 0);
    VARIABLE add_temp_0 : signed(72 DOWNTO 0);
    VARIABLE add_cast_3 : signed(72 DOWNTO 0);
    VARIABLE mul_temp_1 : signed(71 DOWNTO 0);
    VARIABLE add_cast_4 : signed(72 DOWNTO 0);
    VARIABLE add_temp_1 : signed(72 DOWNTO 0);
    VARIABLE add_cast_5 : signed(72 DOWNTO 0);
    VARIABLE mul_temp_2 : signed(71 DOWNTO 0);
    VARIABLE add_cast_6 : signed(72 DOWNTO 0);
    VARIABLE add_temp_2 : signed(72 DOWNTO 0);
    VARIABLE add_cast_7 : signed(72 DOWNTO 0);
    VARIABLE mul_temp_3 : signed(71 DOWNTO 0);
    VARIABLE add_cast_8 : signed(72 DOWNTO 0);
    VARIABLE add_temp_3 : signed(72 DOWNTO 0);
    VARIABLE add_cast_9 : signed(72 DOWNTO 0);
    VARIABLE mul_temp_4 : signed(71 DOWNTO 0);
    VARIABLE add_cast_10 : signed(72 DOWNTO 0);
    VARIABLE add_temp_4 : signed(72 DOWNTO 0);
    VARIABLE add_cast_11 : signed(72 DOWNTO 0);
    VARIABLE mul_temp_5 : signed(71 DOWNTO 0);
    VARIABLE add_cast_12 : signed(72 DOWNTO 0);
    VARIABLE add_temp_5 : signed(72 DOWNTO 0);
    VARIABLE add_cast_13 : signed(72 DOWNTO 0);
    VARIABLE mul_temp_6 : signed(71 DOWNTO 0);
    VARIABLE add_cast_14 : signed(72 DOWNTO 0);
    VARIABLE add_temp_6 : signed(72 DOWNTO 0);
    VARIABLE add_cast_15 : signed(72 DOWNTO 0);
    VARIABLE mul_temp_7 : signed(71 DOWNTO 0);
    VARIABLE add_cast_16 : signed(72 DOWNTO 0);
    VARIABLE add_temp_7 : signed(72 DOWNTO 0);
    VARIABLE add_cast_17 : signed(72 DOWNTO 0);
    VARIABLE mul_temp_8 : signed(71 DOWNTO 0);
    VARIABLE add_cast_18 : signed(72 DOWNTO 0);
    VARIABLE add_temp_8 : signed(72 DOWNTO 0);
    VARIABLE add_cast_19 : signed(72 DOWNTO 0);
    VARIABLE mul_temp_9 : signed(71 DOWNTO 0);
    VARIABLE add_cast_20 : signed(72 DOWNTO 0);
    VARIABLE add_temp_9 : signed(72 DOWNTO 0);
    VARIABLE add_cast_21 : signed(72 DOWNTO 0);
    VARIABLE mul_temp_10 : signed(71 DOWNTO 0);
    VARIABLE add_cast_22 : signed(72 DOWNTO 0);
    VARIABLE add_temp_10 : signed(72 DOWNTO 0);
    VARIABLE add_cast_23 : signed(72 DOWNTO 0);
    VARIABLE mul_temp_11 : signed(71 DOWNTO 0);
    VARIABLE add_cast_24 : signed(72 DOWNTO 0);
    VARIABLE add_temp_11 : signed(72 DOWNTO 0);
    VARIABLE add_cast_25 : signed(72 DOWNTO 0);
    VARIABLE mul_temp_12 : signed(71 DOWNTO 0);
    VARIABLE add_cast_26 : signed(72 DOWNTO 0);
    VARIABLE add_temp_12 : signed(72 DOWNTO 0);
    VARIABLE add_cast_27 : signed(72 DOWNTO 0);
    VARIABLE mul_temp_13 : signed(71 DOWNTO 0);
    VARIABLE add_cast_28 : signed(72 DOWNTO 0);
    VARIABLE add_temp_13 : signed(72 DOWNTO 0);
    VARIABLE add_cast_29 : signed(72 DOWNTO 0);
    VARIABLE mul_temp_14 : signed(71 DOWNTO 0);
    VARIABLE add_cast_30 : signed(72 DOWNTO 0);
    VARIABLE add_temp_14 : signed(72 DOWNTO 0);
    VARIABLE add_cast_31 : signed(72 DOWNTO 0);
    VARIABLE mul_temp_15 : signed(71 DOWNTO 0);
    VARIABLE add_cast_32 : signed(72 DOWNTO 0);
    VARIABLE add_temp_15 : signed(72 DOWNTO 0);
    VARIABLE add_cast_33 : signed(72 DOWNTO 0);
    VARIABLE mul_temp_16 : signed(71 DOWNTO 0);
    VARIABLE add_cast_34 : signed(72 DOWNTO 0);
    VARIABLE add_temp_16 : signed(72 DOWNTO 0);
    VARIABLE add_cast_35 : signed(72 DOWNTO 0);
    VARIABLE mul_temp_17 : signed(71 DOWNTO 0);
    VARIABLE add_cast_36 : signed(72 DOWNTO 0);
    VARIABLE add_temp_17 : signed(72 DOWNTO 0);
    VARIABLE add_cast_37 : signed(72 DOWNTO 0);
    VARIABLE mul_temp_18 : signed(71 DOWNTO 0);
    VARIABLE add_cast_38 : signed(72 DOWNTO 0);
    VARIABLE add_temp_18 : signed(72 DOWNTO 0);
    VARIABLE add_cast_39 : signed(72 DOWNTO 0);
    VARIABLE mul_temp_19 : signed(71 DOWNTO 0);
    VARIABLE add_cast_40 : signed(72 DOWNTO 0);
    VARIABLE add_temp_19 : signed(72 DOWNTO 0);
    VARIABLE add_cast_41 : signed(72 DOWNTO 0);
    VARIABLE mul_temp_20 : signed(71 DOWNTO 0);
    VARIABLE add_cast_42 : signed(72 DOWNTO 0);
    VARIABLE add_temp_20 : signed(72 DOWNTO 0);
    VARIABLE add_cast_43 : signed(72 DOWNTO 0);
    VARIABLE mul_temp_21 : signed(71 DOWNTO 0);
    VARIABLE add_cast_44 : signed(72 DOWNTO 0);
    VARIABLE add_temp_21 : signed(72 DOWNTO 0);
    VARIABLE add_cast_45 : signed(72 DOWNTO 0);
    VARIABLE mul_temp_22 : signed(71 DOWNTO 0);
    VARIABLE add_cast_46 : signed(72 DOWNTO 0);
    VARIABLE add_temp_22 : signed(72 DOWNTO 0);
  BEGIN
    xBuffer_temp := xBuffer;
    wBuffer_temp := wBuffer;
    -- W = weights
    -- X = input
    -- E = error
    -- mu = step size
    -- L = length
    -- X delay pipeline
    -- W delay pipeline
    xBuffer_temp(1 TO 23) := xBuffer(0 TO 22);
    xBuffer_temp(0) := X_signed;
    mu_err := to_signed(16#7FFFFF#, 24) * E_signed;
    IF Adapt = '1' THEN 
      add_cast := resize(wBuffer(0) & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 73);
      mul_temp := mu_err * X_signed;
      add_cast_0 := resize(mul_temp, 73);
      add_temp := add_cast + add_cast_0;
      IF ((add_temp(72) = '0') AND (add_temp(71) /= '0')) OR ((add_temp(72) = '0') AND (add_temp(71 DOWNTO 48) = X"7FFFFF")) THEN 
        wBuffer_temp(0) := X"7FFFFF";
      ELSIF (add_temp(72) = '1') AND (add_temp(71) /= '1') THEN 
        wBuffer_temp(0) := X"800000";
      ELSE 
        wBuffer_temp(0) := add_temp(71 DOWNTO 48) + ('0' & add_temp(47));
      END IF;
      add_cast_1 := resize(wBuffer(1) & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 73);
      mul_temp_0 := mu_err * xBuffer_temp(1);
      add_cast_2 := resize(mul_temp_0, 73);
      add_temp_0 := add_cast_1 + add_cast_2;
      IF ((add_temp_0(72) = '0') AND (add_temp_0(71) /= '0')) OR ((add_temp_0(72) = '0') AND (add_temp_0(71 DOWNTO 48) = X"7FFFFF")) THEN 
        wBuffer_temp(1) := X"7FFFFF";
      ELSIF (add_temp_0(72) = '1') AND (add_temp_0(71) /= '1') THEN 
        wBuffer_temp(1) := X"800000";
      ELSE 
        wBuffer_temp(1) := add_temp_0(71 DOWNTO 48) + ('0' & add_temp_0(47));
      END IF;
      add_cast_3 := resize(wBuffer(2) & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 73);
      mul_temp_1 := mu_err * xBuffer_temp(2);
      add_cast_4 := resize(mul_temp_1, 73);
      add_temp_1 := add_cast_3 + add_cast_4;
      IF ((add_temp_1(72) = '0') AND (add_temp_1(71) /= '0')) OR ((add_temp_1(72) = '0') AND (add_temp_1(71 DOWNTO 48) = X"7FFFFF")) THEN 
        wBuffer_temp(2) := X"7FFFFF";
      ELSIF (add_temp_1(72) = '1') AND (add_temp_1(71) /= '1') THEN 
        wBuffer_temp(2) := X"800000";
      ELSE 
        wBuffer_temp(2) := add_temp_1(71 DOWNTO 48) + ('0' & add_temp_1(47));
      END IF;
      add_cast_5 := resize(wBuffer(3) & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 73);
      mul_temp_2 := mu_err * xBuffer_temp(3);
      add_cast_6 := resize(mul_temp_2, 73);
      add_temp_2 := add_cast_5 + add_cast_6;
      IF ((add_temp_2(72) = '0') AND (add_temp_2(71) /= '0')) OR ((add_temp_2(72) = '0') AND (add_temp_2(71 DOWNTO 48) = X"7FFFFF")) THEN 
        wBuffer_temp(3) := X"7FFFFF";
      ELSIF (add_temp_2(72) = '1') AND (add_temp_2(71) /= '1') THEN 
        wBuffer_temp(3) := X"800000";
      ELSE 
        wBuffer_temp(3) := add_temp_2(71 DOWNTO 48) + ('0' & add_temp_2(47));
      END IF;
      add_cast_7 := resize(wBuffer(4) & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 73);
      mul_temp_3 := mu_err * xBuffer_temp(4);
      add_cast_8 := resize(mul_temp_3, 73);
      add_temp_3 := add_cast_7 + add_cast_8;
      IF ((add_temp_3(72) = '0') AND (add_temp_3(71) /= '0')) OR ((add_temp_3(72) = '0') AND (add_temp_3(71 DOWNTO 48) = X"7FFFFF")) THEN 
        wBuffer_temp(4) := X"7FFFFF";
      ELSIF (add_temp_3(72) = '1') AND (add_temp_3(71) /= '1') THEN 
        wBuffer_temp(4) := X"800000";
      ELSE 
        wBuffer_temp(4) := add_temp_3(71 DOWNTO 48) + ('0' & add_temp_3(47));
      END IF;
      add_cast_9 := resize(wBuffer(5) & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 73);
      mul_temp_4 := mu_err * xBuffer_temp(5);
      add_cast_10 := resize(mul_temp_4, 73);
      add_temp_4 := add_cast_9 + add_cast_10;
      IF ((add_temp_4(72) = '0') AND (add_temp_4(71) /= '0')) OR ((add_temp_4(72) = '0') AND (add_temp_4(71 DOWNTO 48) = X"7FFFFF")) THEN 
        wBuffer_temp(5) := X"7FFFFF";
      ELSIF (add_temp_4(72) = '1') AND (add_temp_4(71) /= '1') THEN 
        wBuffer_temp(5) := X"800000";
      ELSE 
        wBuffer_temp(5) := add_temp_4(71 DOWNTO 48) + ('0' & add_temp_4(47));
      END IF;
      add_cast_11 := resize(wBuffer(6) & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 73);
      mul_temp_5 := mu_err * xBuffer_temp(6);
      add_cast_12 := resize(mul_temp_5, 73);
      add_temp_5 := add_cast_11 + add_cast_12;
      IF ((add_temp_5(72) = '0') AND (add_temp_5(71) /= '0')) OR ((add_temp_5(72) = '0') AND (add_temp_5(71 DOWNTO 48) = X"7FFFFF")) THEN 
        wBuffer_temp(6) := X"7FFFFF";
      ELSIF (add_temp_5(72) = '1') AND (add_temp_5(71) /= '1') THEN 
        wBuffer_temp(6) := X"800000";
      ELSE 
        wBuffer_temp(6) := add_temp_5(71 DOWNTO 48) + ('0' & add_temp_5(47));
      END IF;
      add_cast_13 := resize(wBuffer(7) & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 73);
      mul_temp_6 := mu_err * xBuffer_temp(7);
      add_cast_14 := resize(mul_temp_6, 73);
      add_temp_6 := add_cast_13 + add_cast_14;
      IF ((add_temp_6(72) = '0') AND (add_temp_6(71) /= '0')) OR ((add_temp_6(72) = '0') AND (add_temp_6(71 DOWNTO 48) = X"7FFFFF")) THEN 
        wBuffer_temp(7) := X"7FFFFF";
      ELSIF (add_temp_6(72) = '1') AND (add_temp_6(71) /= '1') THEN 
        wBuffer_temp(7) := X"800000";
      ELSE 
        wBuffer_temp(7) := add_temp_6(71 DOWNTO 48) + ('0' & add_temp_6(47));
      END IF;
      add_cast_15 := resize(wBuffer(8) & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 73);
      mul_temp_7 := mu_err * xBuffer_temp(8);
      add_cast_16 := resize(mul_temp_7, 73);
      add_temp_7 := add_cast_15 + add_cast_16;
      IF ((add_temp_7(72) = '0') AND (add_temp_7(71) /= '0')) OR ((add_temp_7(72) = '0') AND (add_temp_7(71 DOWNTO 48) = X"7FFFFF")) THEN 
        wBuffer_temp(8) := X"7FFFFF";
      ELSIF (add_temp_7(72) = '1') AND (add_temp_7(71) /= '1') THEN 
        wBuffer_temp(8) := X"800000";
      ELSE 
        wBuffer_temp(8) := add_temp_7(71 DOWNTO 48) + ('0' & add_temp_7(47));
      END IF;
      add_cast_17 := resize(wBuffer(9) & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 73);
      mul_temp_8 := mu_err * xBuffer_temp(9);
      add_cast_18 := resize(mul_temp_8, 73);
      add_temp_8 := add_cast_17 + add_cast_18;
      IF ((add_temp_8(72) = '0') AND (add_temp_8(71) /= '0')) OR ((add_temp_8(72) = '0') AND (add_temp_8(71 DOWNTO 48) = X"7FFFFF")) THEN 
        wBuffer_temp(9) := X"7FFFFF";
      ELSIF (add_temp_8(72) = '1') AND (add_temp_8(71) /= '1') THEN 
        wBuffer_temp(9) := X"800000";
      ELSE 
        wBuffer_temp(9) := add_temp_8(71 DOWNTO 48) + ('0' & add_temp_8(47));
      END IF;
      add_cast_19 := resize(wBuffer(10) & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 73);
      mul_temp_9 := mu_err * xBuffer_temp(10);
      add_cast_20 := resize(mul_temp_9, 73);
      add_temp_9 := add_cast_19 + add_cast_20;
      IF ((add_temp_9(72) = '0') AND (add_temp_9(71) /= '0')) OR ((add_temp_9(72) = '0') AND (add_temp_9(71 DOWNTO 48) = X"7FFFFF")) THEN 
        wBuffer_temp(10) := X"7FFFFF";
      ELSIF (add_temp_9(72) = '1') AND (add_temp_9(71) /= '1') THEN 
        wBuffer_temp(10) := X"800000";
      ELSE 
        wBuffer_temp(10) := add_temp_9(71 DOWNTO 48) + ('0' & add_temp_9(47));
      END IF;
      add_cast_21 := resize(wBuffer(11) & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 73);
      mul_temp_10 := mu_err * xBuffer_temp(11);
      add_cast_22 := resize(mul_temp_10, 73);
      add_temp_10 := add_cast_21 + add_cast_22;
      IF ((add_temp_10(72) = '0') AND (add_temp_10(71) /= '0')) OR ((add_temp_10(72) = '0') AND (add_temp_10(71 DOWNTO 48) = X"7FFFFF")) THEN 
        wBuffer_temp(11) := X"7FFFFF";
      ELSIF (add_temp_10(72) = '1') AND (add_temp_10(71) /= '1') THEN 
        wBuffer_temp(11) := X"800000";
      ELSE 
        wBuffer_temp(11) := add_temp_10(71 DOWNTO 48) + ('0' & add_temp_10(47));
      END IF;
      add_cast_23 := resize(wBuffer(12) & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 73);
      mul_temp_11 := mu_err * xBuffer_temp(12);
      add_cast_24 := resize(mul_temp_11, 73);
      add_temp_11 := add_cast_23 + add_cast_24;
      IF ((add_temp_11(72) = '0') AND (add_temp_11(71) /= '0')) OR ((add_temp_11(72) = '0') AND (add_temp_11(71 DOWNTO 48) = X"7FFFFF")) THEN 
        wBuffer_temp(12) := X"7FFFFF";
      ELSIF (add_temp_11(72) = '1') AND (add_temp_11(71) /= '1') THEN 
        wBuffer_temp(12) := X"800000";
      ELSE 
        wBuffer_temp(12) := add_temp_11(71 DOWNTO 48) + ('0' & add_temp_11(47));
      END IF;
      add_cast_25 := resize(wBuffer(13) & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 73);
      mul_temp_12 := mu_err * xBuffer_temp(13);
      add_cast_26 := resize(mul_temp_12, 73);
      add_temp_12 := add_cast_25 + add_cast_26;
      IF ((add_temp_12(72) = '0') AND (add_temp_12(71) /= '0')) OR ((add_temp_12(72) = '0') AND (add_temp_12(71 DOWNTO 48) = X"7FFFFF")) THEN 
        wBuffer_temp(13) := X"7FFFFF";
      ELSIF (add_temp_12(72) = '1') AND (add_temp_12(71) /= '1') THEN 
        wBuffer_temp(13) := X"800000";
      ELSE 
        wBuffer_temp(13) := add_temp_12(71 DOWNTO 48) + ('0' & add_temp_12(47));
      END IF;
      add_cast_27 := resize(wBuffer(14) & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 73);
      mul_temp_13 := mu_err * xBuffer_temp(14);
      add_cast_28 := resize(mul_temp_13, 73);
      add_temp_13 := add_cast_27 + add_cast_28;
      IF ((add_temp_13(72) = '0') AND (add_temp_13(71) /= '0')) OR ((add_temp_13(72) = '0') AND (add_temp_13(71 DOWNTO 48) = X"7FFFFF")) THEN 
        wBuffer_temp(14) := X"7FFFFF";
      ELSIF (add_temp_13(72) = '1') AND (add_temp_13(71) /= '1') THEN 
        wBuffer_temp(14) := X"800000";
      ELSE 
        wBuffer_temp(14) := add_temp_13(71 DOWNTO 48) + ('0' & add_temp_13(47));
      END IF;
      add_cast_29 := resize(wBuffer(15) & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 73);
      mul_temp_14 := mu_err * xBuffer_temp(15);
      add_cast_30 := resize(mul_temp_14, 73);
      add_temp_14 := add_cast_29 + add_cast_30;
      IF ((add_temp_14(72) = '0') AND (add_temp_14(71) /= '0')) OR ((add_temp_14(72) = '0') AND (add_temp_14(71 DOWNTO 48) = X"7FFFFF")) THEN 
        wBuffer_temp(15) := X"7FFFFF";
      ELSIF (add_temp_14(72) = '1') AND (add_temp_14(71) /= '1') THEN 
        wBuffer_temp(15) := X"800000";
      ELSE 
        wBuffer_temp(15) := add_temp_14(71 DOWNTO 48) + ('0' & add_temp_14(47));
      END IF;
      add_cast_31 := resize(wBuffer(16) & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 73);
      mul_temp_15 := mu_err * xBuffer_temp(16);
      add_cast_32 := resize(mul_temp_15, 73);
      add_temp_15 := add_cast_31 + add_cast_32;
      IF ((add_temp_15(72) = '0') AND (add_temp_15(71) /= '0')) OR ((add_temp_15(72) = '0') AND (add_temp_15(71 DOWNTO 48) = X"7FFFFF")) THEN 
        wBuffer_temp(16) := X"7FFFFF";
      ELSIF (add_temp_15(72) = '1') AND (add_temp_15(71) /= '1') THEN 
        wBuffer_temp(16) := X"800000";
      ELSE 
        wBuffer_temp(16) := add_temp_15(71 DOWNTO 48) + ('0' & add_temp_15(47));
      END IF;
      add_cast_33 := resize(wBuffer(17) & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 73);
      mul_temp_16 := mu_err * xBuffer_temp(17);
      add_cast_34 := resize(mul_temp_16, 73);
      add_temp_16 := add_cast_33 + add_cast_34;
      IF ((add_temp_16(72) = '0') AND (add_temp_16(71) /= '0')) OR ((add_temp_16(72) = '0') AND (add_temp_16(71 DOWNTO 48) = X"7FFFFF")) THEN 
        wBuffer_temp(17) := X"7FFFFF";
      ELSIF (add_temp_16(72) = '1') AND (add_temp_16(71) /= '1') THEN 
        wBuffer_temp(17) := X"800000";
      ELSE 
        wBuffer_temp(17) := add_temp_16(71 DOWNTO 48) + ('0' & add_temp_16(47));
      END IF;
      add_cast_35 := resize(wBuffer(18) & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 73);
      mul_temp_17 := mu_err * xBuffer_temp(18);
      add_cast_36 := resize(mul_temp_17, 73);
      add_temp_17 := add_cast_35 + add_cast_36;
      IF ((add_temp_17(72) = '0') AND (add_temp_17(71) /= '0')) OR ((add_temp_17(72) = '0') AND (add_temp_17(71 DOWNTO 48) = X"7FFFFF")) THEN 
        wBuffer_temp(18) := X"7FFFFF";
      ELSIF (add_temp_17(72) = '1') AND (add_temp_17(71) /= '1') THEN 
        wBuffer_temp(18) := X"800000";
      ELSE 
        wBuffer_temp(18) := add_temp_17(71 DOWNTO 48) + ('0' & add_temp_17(47));
      END IF;
      add_cast_37 := resize(wBuffer(19) & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 73);
      mul_temp_18 := mu_err * xBuffer_temp(19);
      add_cast_38 := resize(mul_temp_18, 73);
      add_temp_18 := add_cast_37 + add_cast_38;
      IF ((add_temp_18(72) = '0') AND (add_temp_18(71) /= '0')) OR ((add_temp_18(72) = '0') AND (add_temp_18(71 DOWNTO 48) = X"7FFFFF")) THEN 
        wBuffer_temp(19) := X"7FFFFF";
      ELSIF (add_temp_18(72) = '1') AND (add_temp_18(71) /= '1') THEN 
        wBuffer_temp(19) := X"800000";
      ELSE 
        wBuffer_temp(19) := add_temp_18(71 DOWNTO 48) + ('0' & add_temp_18(47));
      END IF;
      add_cast_39 := resize(wBuffer(20) & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 73);
      mul_temp_19 := mu_err * xBuffer_temp(20);
      add_cast_40 := resize(mul_temp_19, 73);
      add_temp_19 := add_cast_39 + add_cast_40;
      IF ((add_temp_19(72) = '0') AND (add_temp_19(71) /= '0')) OR ((add_temp_19(72) = '0') AND (add_temp_19(71 DOWNTO 48) = X"7FFFFF")) THEN 
        wBuffer_temp(20) := X"7FFFFF";
      ELSIF (add_temp_19(72) = '1') AND (add_temp_19(71) /= '1') THEN 
        wBuffer_temp(20) := X"800000";
      ELSE 
        wBuffer_temp(20) := add_temp_19(71 DOWNTO 48) + ('0' & add_temp_19(47));
      END IF;
      add_cast_41 := resize(wBuffer(21) & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 73);
      mul_temp_20 := mu_err * xBuffer_temp(21);
      add_cast_42 := resize(mul_temp_20, 73);
      add_temp_20 := add_cast_41 + add_cast_42;
      IF ((add_temp_20(72) = '0') AND (add_temp_20(71) /= '0')) OR ((add_temp_20(72) = '0') AND (add_temp_20(71 DOWNTO 48) = X"7FFFFF")) THEN 
        wBuffer_temp(21) := X"7FFFFF";
      ELSIF (add_temp_20(72) = '1') AND (add_temp_20(71) /= '1') THEN 
        wBuffer_temp(21) := X"800000";
      ELSE 
        wBuffer_temp(21) := add_temp_20(71 DOWNTO 48) + ('0' & add_temp_20(47));
      END IF;
      add_cast_43 := resize(wBuffer(22) & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 73);
      mul_temp_21 := mu_err * xBuffer_temp(22);
      add_cast_44 := resize(mul_temp_21, 73);
      add_temp_21 := add_cast_43 + add_cast_44;
      IF ((add_temp_21(72) = '0') AND (add_temp_21(71) /= '0')) OR ((add_temp_21(72) = '0') AND (add_temp_21(71 DOWNTO 48) = X"7FFFFF")) THEN 
        wBuffer_temp(22) := X"7FFFFF";
      ELSIF (add_temp_21(72) = '1') AND (add_temp_21(71) /= '1') THEN 
        wBuffer_temp(22) := X"800000";
      ELSE 
        wBuffer_temp(22) := add_temp_21(71 DOWNTO 48) + ('0' & add_temp_21(47));
      END IF;
      add_cast_45 := resize(wBuffer(23) & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 73);
      mul_temp_22 := mu_err * xBuffer_temp(23);
      add_cast_46 := resize(mul_temp_22, 73);
      add_temp_22 := add_cast_45 + add_cast_46;
      IF ((add_temp_22(72) = '0') AND (add_temp_22(71) /= '0')) OR ((add_temp_22(72) = '0') AND (add_temp_22(71 DOWNTO 48) = X"7FFFFF")) THEN 
        wBuffer_temp(23) := X"7FFFFF";
      ELSIF (add_temp_22(72) = '1') AND (add_temp_22(71) /= '1') THEN 
        wBuffer_temp(23) := X"800000";
      ELSE 
        wBuffer_temp(23) := add_temp_22(71 DOWNTO 48) + ('0' & add_temp_22(47));
      END IF;
      --the above statement has been unwrapped to force HDL coder to not
      --use FOR-GENERATE statements
    END IF;
    W_tmp <= wBuffer_temp;
    xBuffer_next <= xBuffer_temp;
    wBuffer_next <= wBuffer_temp;
  END PROCESS LMS_Update_24_1_output;


  outputgen: FOR k IN 0 TO 23 GENERATE
    W(k) <= std_logic_vector(W_tmp(k));
  END GENERATE;

END rtl;

