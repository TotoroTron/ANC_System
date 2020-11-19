-- -------------------------------------------------------------
-- 
-- File Name: hdl_prj\hdlsrc\LMSUpdateTester\LMSUpdate.vhd
-- Created: 2020-11-18 17:18:28
-- 
-- Generated by MATLAB 9.7 and HDL Coder 3.15
-- 
-- -------------------------------------------------------------


-- -------------------------------------------------------------
-- 
-- Module: LMSUpdate
-- Source Path: LMSUpdateTester/LMSUpdateSystem/LMSUpdate
-- Hierarchy Level: 1
-- 
-- -------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.top_level_pkg.ALL;

ENTITY LMS_Update_12 IS
  PORT( clk                               :   IN    std_logic;
        reset                             :   IN    std_logic;
        enb                               :   IN    std_logic;
        X                                 :   IN    std_logic_vector(23 DOWNTO 0);  -- sfix24_En24
        E                                 :   IN    std_logic_vector(23 DOWNTO 0);  -- sfix24_En24
        Adapt                             :   IN    std_logic;
        W                                 :   OUT   vector_of_std_logic_vector24(0 TO 11)  -- sfix24_En24 [12]
        );
END LMS_Update_12;


ARCHITECTURE rtl OF LMS_Update_12 IS

  -- Signals
  SIGNAL X_signed                         : signed(23 DOWNTO 0);  -- sfix24_En24
  SIGNAL E_signed                         : signed(23 DOWNTO 0);  -- sfix24_En24
  SIGNAL W_tmp                            : vector_of_signed24(0 TO 11);  -- sfix24_En24 [12]
  SIGNAL xBuffer                          : vector_of_signed24(0 TO 11);  -- sfix24 [12]
  SIGNAL wBuffer                          : vector_of_signed24(0 TO 11);  -- sfix24 [12]
  SIGNAL xBuffer_next                     : vector_of_signed24(0 TO 11);  -- sfix24_En24 [12]
  SIGNAL wBuffer_next                     : vector_of_signed24(0 TO 11);  -- sfix24_En24 [12]

BEGIN
  X_signed <= signed(X);

  E_signed <= signed(E);

    LMSUpdate_1_process : PROCESS (clk)
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
    END PROCESS LMSUpdate_1_process;

  LMSUpdate_1_output : PROCESS (Adapt, E_signed, X_signed, wBuffer, xBuffer)
    VARIABLE xBuffer_temp   : vector_of_signed24(0 TO 11) := (others => (others => '0'));
    VARIABLE wBuffer_temp   : vector_of_signed24(0 TO 11) := (others => (others => '0'));
    VARIABLE add_cast       : signed(74 DOWNTO 0) := (others => '0');
    VARIABLE cast           : signed(47 DOWNTO 0) := (others => '0');
    VARIABLE mul_temp       : signed(71 DOWNTO 0) := (others => '0');
    VARIABLE add_cast_0     : signed(74 DOWNTO 0) := (others => '0');
    VARIABLE add_temp       : signed(74 DOWNTO 0) := (others => '0');
    VARIABLE add_cast_1     : signed(74 DOWNTO 0) := (others => '0');
    VARIABLE cast_0         : signed(47 DOWNTO 0) := (others => '0');
    VARIABLE mul_temp_0     : signed(71 DOWNTO 0) := (others => '0');
    VARIABLE add_cast_2     : signed(74 DOWNTO 0) := (others => '0');
    VARIABLE add_temp_0     : signed(74 DOWNTO 0) := (others => '0');
    VARIABLE add_cast_3     : signed(74 DOWNTO 0) := (others => '0');
    VARIABLE cast_1         : signed(47 DOWNTO 0) := (others => '0');
    VARIABLE mul_temp_1     : signed(71 DOWNTO 0) := (others => '0');
    VARIABLE add_cast_4     : signed(74 DOWNTO 0) := (others => '0');
    VARIABLE add_temp_1     : signed(74 DOWNTO 0) := (others => '0');
    VARIABLE add_cast_5     : signed(74 DOWNTO 0) := (others => '0');
    VARIABLE cast_2         : signed(47 DOWNTO 0) := (others => '0');
    VARIABLE mul_temp_2     : signed(71 DOWNTO 0) := (others => '0');
    VARIABLE add_cast_6     : signed(74 DOWNTO 0) := (others => '0');
    VARIABLE add_temp_2     : signed(74 DOWNTO 0) := (others => '0');
    VARIABLE add_cast_7     : signed(74 DOWNTO 0) := (others => '0');
    VARIABLE cast_3         : signed(47 DOWNTO 0) := (others => '0');
    VARIABLE mul_temp_3     : signed(71 DOWNTO 0) := (others => '0');
    VARIABLE add_cast_8     : signed(74 DOWNTO 0) := (others => '0');
    VARIABLE add_temp_3     : signed(74 DOWNTO 0) := (others => '0');
    VARIABLE add_cast_9     : signed(74 DOWNTO 0) := (others => '0');
    VARIABLE cast_4         : signed(47 DOWNTO 0) := (others => '0');
    VARIABLE mul_temp_4     : signed(71 DOWNTO 0) := (others => '0');
    VARIABLE add_cast_10    : signed(74 DOWNTO 0) := (others => '0');
    VARIABLE add_temp_4     : signed(74 DOWNTO 0) := (others => '0');
    VARIABLE add_cast_11    : signed(74 DOWNTO 0) := (others => '0');
    VARIABLE cast_5         : signed(47 DOWNTO 0) := (others => '0');
    VARIABLE mul_temp_5     : signed(71 DOWNTO 0) := (others => '0');
    VARIABLE add_cast_12    : signed(74 DOWNTO 0) := (others => '0');
    VARIABLE add_temp_5     : signed(74 DOWNTO 0) := (others => '0');
    VARIABLE add_cast_13    : signed(74 DOWNTO 0) := (others => '0');
    VARIABLE cast_6         : signed(47 DOWNTO 0) := (others => '0');
    VARIABLE mul_temp_6     : signed(71 DOWNTO 0) := (others => '0');
    VARIABLE add_cast_14    : signed(74 DOWNTO 0) := (others => '0');
    VARIABLE add_temp_6     : signed(74 DOWNTO 0) := (others => '0');
    VARIABLE add_cast_15    : signed(74 DOWNTO 0) := (others => '0');
    VARIABLE cast_7         : signed(47 DOWNTO 0) := (others => '0');
    VARIABLE mul_temp_7     : signed(71 DOWNTO 0) := (others => '0');
    VARIABLE add_cast_16    : signed(74 DOWNTO 0) := (others => '0');
    VARIABLE add_temp_7     : signed(74 DOWNTO 0) := (others => '0');
    VARIABLE add_cast_17    : signed(74 DOWNTO 0) := (others => '0');
    VARIABLE cast_8         : signed(47 DOWNTO 0) := (others => '0');
    VARIABLE mul_temp_8     : signed(71 DOWNTO 0) := (others => '0');
    VARIABLE add_cast_18    : signed(74 DOWNTO 0) := (others => '0');
    VARIABLE add_temp_8     : signed(74 DOWNTO 0) := (others => '0');
    VARIABLE add_cast_19    : signed(74 DOWNTO 0) := (others => '0');
    VARIABLE cast_9         : signed(47 DOWNTO 0) := (others => '0');
    VARIABLE mul_temp_9     : signed(71 DOWNTO 0) := (others => '0');
    VARIABLE add_cast_20    : signed(74 DOWNTO 0) := (others => '0');
    VARIABLE add_temp_9     : signed(74 DOWNTO 0) := (others => '0');
    VARIABLE add_cast_21    : signed(74 DOWNTO 0) := (others => '0');
    VARIABLE cast_10        : signed(47 DOWNTO 0) := (others => '0');
    VARIABLE mul_temp_10    : signed(71 DOWNTO 0) := (others => '0');
    VARIABLE add_cast_22    : signed(74 DOWNTO 0) := (others => '0');
    VARIABLE add_temp_10    : signed(74 DOWNTO 0) := (others => '0');
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
    -- 	xBuffer(2:32) = xBuffer(1:31);
    xBuffer_temp(1 TO 11) := xBuffer(0 TO 10);
    xBuffer_temp(0) := X_signed;
    IF Adapt = '1' THEN 
      add_cast := resize(wBuffer(0) & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 75);
      cast := resize(E_signed & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 48);
      mul_temp := cast * X_signed;
      add_cast_0 := resize(mul_temp, 75);
      add_temp := add_cast + add_cast_0;
      IF ((add_temp(74) = '0') AND (add_temp(73) /= '0')) OR ((add_temp(74) = '0') AND (add_temp(73 DOWNTO 50) = X"7FFFFF")) THEN 
        wBuffer_temp(0) := X"7FFFFF";
      ELSIF (add_temp(74) = '1') AND (add_temp(73) /= '1') THEN 
        wBuffer_temp(0) := X"800000";
      ELSE 
        wBuffer_temp(0) := add_temp(73 DOWNTO 50) + ('0' & add_temp(49));
      END IF;
      add_cast_1 := resize(wBuffer(1) & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 75);
      cast_0 := resize(E_signed & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 48);
      mul_temp_0 := cast_0 * xBuffer_temp(1);
      add_cast_2 := resize(mul_temp_0, 75);
      add_temp_0 := add_cast_1 + add_cast_2;
      IF ((add_temp_0(74) = '0') AND (add_temp_0(73) /= '0')) OR ((add_temp_0(74) = '0') AND (add_temp_0(73 DOWNTO 50) = X"7FFFFF")) THEN 
        wBuffer_temp(1) := X"7FFFFF";
      ELSIF (add_temp_0(74) = '1') AND (add_temp_0(73) /= '1') THEN 
        wBuffer_temp(1) := X"800000";
      ELSE 
        wBuffer_temp(1) := add_temp_0(73 DOWNTO 50) + ('0' & add_temp_0(49));
      END IF;
      add_cast_3 := resize(wBuffer(2) & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 75);
      cast_1 := resize(E_signed & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 48);
      mul_temp_1 := cast_1 * xBuffer_temp(2);
      add_cast_4 := resize(mul_temp_1, 75);
      add_temp_1 := add_cast_3 + add_cast_4;
      IF ((add_temp_1(74) = '0') AND (add_temp_1(73) /= '0')) OR ((add_temp_1(74) = '0') AND (add_temp_1(73 DOWNTO 50) = X"7FFFFF")) THEN 
        wBuffer_temp(2) := X"7FFFFF";
      ELSIF (add_temp_1(74) = '1') AND (add_temp_1(73) /= '1') THEN 
        wBuffer_temp(2) := X"800000";
      ELSE 
        wBuffer_temp(2) := add_temp_1(73 DOWNTO 50) + ('0' & add_temp_1(49));
      END IF;
      add_cast_5 := resize(wBuffer(3) & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 75);
      cast_2 := resize(E_signed & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 48);
      mul_temp_2 := cast_2 * xBuffer_temp(3);
      add_cast_6 := resize(mul_temp_2, 75);
      add_temp_2 := add_cast_5 + add_cast_6;
      IF ((add_temp_2(74) = '0') AND (add_temp_2(73) /= '0')) OR ((add_temp_2(74) = '0') AND (add_temp_2(73 DOWNTO 50) = X"7FFFFF")) THEN 
        wBuffer_temp(3) := X"7FFFFF";
      ELSIF (add_temp_2(74) = '1') AND (add_temp_2(73) /= '1') THEN 
        wBuffer_temp(3) := X"800000";
      ELSE 
        wBuffer_temp(3) := add_temp_2(73 DOWNTO 50) + ('0' & add_temp_2(49));
      END IF;
      add_cast_7 := resize(wBuffer(4) & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 75);
      cast_3 := resize(E_signed & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 48);
      mul_temp_3 := cast_3 * xBuffer_temp(4);
      add_cast_8 := resize(mul_temp_3, 75);
      add_temp_3 := add_cast_7 + add_cast_8;
      IF ((add_temp_3(74) = '0') AND (add_temp_3(73) /= '0')) OR ((add_temp_3(74) = '0') AND (add_temp_3(73 DOWNTO 50) = X"7FFFFF")) THEN 
        wBuffer_temp(4) := X"7FFFFF";
      ELSIF (add_temp_3(74) = '1') AND (add_temp_3(73) /= '1') THEN 
        wBuffer_temp(4) := X"800000";
      ELSE 
        wBuffer_temp(4) := add_temp_3(73 DOWNTO 50) + ('0' & add_temp_3(49));
      END IF;
      add_cast_9 := resize(wBuffer(5) & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 75);
      cast_4 := resize(E_signed & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 48);
      mul_temp_4 := cast_4 * xBuffer_temp(5);
      add_cast_10 := resize(mul_temp_4, 75);
      add_temp_4 := add_cast_9 + add_cast_10;
      IF ((add_temp_4(74) = '0') AND (add_temp_4(73) /= '0')) OR ((add_temp_4(74) = '0') AND (add_temp_4(73 DOWNTO 50) = X"7FFFFF")) THEN 
        wBuffer_temp(5) := X"7FFFFF";
      ELSIF (add_temp_4(74) = '1') AND (add_temp_4(73) /= '1') THEN 
        wBuffer_temp(5) := X"800000";
      ELSE 
        wBuffer_temp(5) := add_temp_4(73 DOWNTO 50) + ('0' & add_temp_4(49));
      END IF;
      add_cast_11 := resize(wBuffer(6) & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 75);
      cast_5 := resize(E_signed & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 48);
      mul_temp_5 := cast_5 * xBuffer_temp(6);
      add_cast_12 := resize(mul_temp_5, 75);
      add_temp_5 := add_cast_11 + add_cast_12;
      IF ((add_temp_5(74) = '0') AND (add_temp_5(73) /= '0')) OR ((add_temp_5(74) = '0') AND (add_temp_5(73 DOWNTO 50) = X"7FFFFF")) THEN 
        wBuffer_temp(6) := X"7FFFFF";
      ELSIF (add_temp_5(74) = '1') AND (add_temp_5(73) /= '1') THEN 
        wBuffer_temp(6) := X"800000";
      ELSE 
        wBuffer_temp(6) := add_temp_5(73 DOWNTO 50) + ('0' & add_temp_5(49));
      END IF;
      add_cast_13 := resize(wBuffer(7) & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 75);
      cast_6 := resize(E_signed & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 48);
      mul_temp_6 := cast_6 * xBuffer_temp(7);
      add_cast_14 := resize(mul_temp_6, 75);
      add_temp_6 := add_cast_13 + add_cast_14;
      IF ((add_temp_6(74) = '0') AND (add_temp_6(73) /= '0')) OR ((add_temp_6(74) = '0') AND (add_temp_6(73 DOWNTO 50) = X"7FFFFF")) THEN 
        wBuffer_temp(7) := X"7FFFFF";
      ELSIF (add_temp_6(74) = '1') AND (add_temp_6(73) /= '1') THEN 
        wBuffer_temp(7) := X"800000";
      ELSE 
        wBuffer_temp(7) := add_temp_6(73 DOWNTO 50) + ('0' & add_temp_6(49));
      END IF;
      add_cast_15 := resize(wBuffer(8) & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 75);
      cast_7 := resize(E_signed & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 48);
      mul_temp_7 := cast_7 * xBuffer_temp(8);
      add_cast_16 := resize(mul_temp_7, 75);
      add_temp_7 := add_cast_15 + add_cast_16;
      IF ((add_temp_7(74) = '0') AND (add_temp_7(73) /= '0')) OR ((add_temp_7(74) = '0') AND (add_temp_7(73 DOWNTO 50) = X"7FFFFF")) THEN 
        wBuffer_temp(8) := X"7FFFFF";
      ELSIF (add_temp_7(74) = '1') AND (add_temp_7(73) /= '1') THEN 
        wBuffer_temp(8) := X"800000";
      ELSE 
        wBuffer_temp(8) := add_temp_7(73 DOWNTO 50) + ('0' & add_temp_7(49));
      END IF;
      add_cast_17 := resize(wBuffer(9) & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 75);
      cast_8 := resize(E_signed & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 48);
      mul_temp_8 := cast_8 * xBuffer_temp(9);
      add_cast_18 := resize(mul_temp_8, 75);
      add_temp_8 := add_cast_17 + add_cast_18;
      IF ((add_temp_8(74) = '0') AND (add_temp_8(73) /= '0')) OR ((add_temp_8(74) = '0') AND (add_temp_8(73 DOWNTO 50) = X"7FFFFF")) THEN 
        wBuffer_temp(9) := X"7FFFFF";
      ELSIF (add_temp_8(74) = '1') AND (add_temp_8(73) /= '1') THEN 
        wBuffer_temp(9) := X"800000";
      ELSE 
        wBuffer_temp(9) := add_temp_8(73 DOWNTO 50) + ('0' & add_temp_8(49));
      END IF;
      add_cast_19 := resize(wBuffer(10) & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 75);
      cast_9 := resize(E_signed & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 48);
      mul_temp_9 := cast_9 * xBuffer_temp(10);
      add_cast_20 := resize(mul_temp_9, 75);
      add_temp_9 := add_cast_19 + add_cast_20;
      IF ((add_temp_9(74) = '0') AND (add_temp_9(73) /= '0')) OR ((add_temp_9(74) = '0') AND (add_temp_9(73 DOWNTO 50) = X"7FFFFF")) THEN 
        wBuffer_temp(10) := X"7FFFFF";
      ELSIF (add_temp_9(74) = '1') AND (add_temp_9(73) /= '1') THEN 
        wBuffer_temp(10) := X"800000";
      ELSE 
        wBuffer_temp(10) := add_temp_9(73 DOWNTO 50) + ('0' & add_temp_9(49));
      END IF;
      add_cast_21 := resize(wBuffer(11) & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 75);
      cast_10 := resize(E_signed & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 48);
      mul_temp_10 := cast_10 * xBuffer_temp(11);
      add_cast_22 := resize(mul_temp_10, 75);
      add_temp_10 := add_cast_21 + add_cast_22;
      IF ((add_temp_10(74) = '0') AND (add_temp_10(73) /= '0')) OR ((add_temp_10(74) = '0') AND (add_temp_10(73 DOWNTO 50) = X"7FFFFF")) THEN 
        wBuffer_temp(11) := X"7FFFFF";
      ELSIF (add_temp_10(74) = '1') AND (add_temp_10(73) /= '1') THEN 
        wBuffer_temp(11) := X"800000";
      ELSE 
        wBuffer_temp(11) := add_temp_10(73 DOWNTO 50) + ('0' & add_temp_10(49));
      END IF;
      --         wBuffer(13) = wBuffer(13) + 0.0625*E*xBuffer(13);
      --         wBuffer(14) = wBuffer(14) + 0.0625*E*xBuffer(14);
      --         wBuffer(15) = wBuffer(15) + 0.0625*E*xBuffer(15);
      --         wBuffer(16) = wBuffer(16) + 0.0625*E*xBuffer(16);
      --         wBuffer(17) = wBuffer(17) + 0.0625*E*xBuffer(17);
      --         wBuffer(18) = wBuffer(18) + 0.0625*E*xBuffer(18);
      --         wBuffer(19) = wBuffer(19) + 0.0625*E*xBuffer(19);
      --         wBuffer(20) = wBuffer(20) + 0.0625*E*xBuffer(20);
      --         wBuffer(21) = wBuffer(21) + 0.0625*E*xBuffer(21);
      --         wBuffer(22) = wBuffer(22) + 0.0625*E*xBuffer(22);
      --         wBuffer(23) = wBuffer(23) + 0.0625*E*xBuffer(23);
      --         wBuffer(24) = wBuffer(24) + 0.0625*E*xBuffer(24);
      --         wBuffer(25) = wBuffer(25) + 0.0625*E*xBuffer(25);
      --         wBuffer(26) = wBuffer(26) + 0.0625*E*xBuffer(26);
      --         wBuffer(27) = wBuffer(27) + 0.0625*E*xBuffer(27);
      --         wBuffer(28) = wBuffer(28) + 0.0625*E*xBuffer(28);
      --         wBuffer(29) = wBuffer(29) + 0.0625*E*xBuffer(29);
      --         wBuffer(30) = wBuffer(30) + 0.0625*E*xBuffer(30);
      --         wBuffer(31) = wBuffer(31) + 0.0625*E*xBuffer(31);
      --         wBuffer(32) = wBuffer(32) + 0.0625*E*xBuffer(32);
      --wBuffer(:) = (wBuffer) + 0.0625*E*(xBuffer);
      --the above statement has been unwrapped to force HDL coder to not
      --use FOR-GENERATE statements
    END IF;
    W_tmp <= wBuffer_temp;
    xBuffer_next <= xBuffer_temp;
    wBuffer_next <= wBuffer_temp;
  END PROCESS LMSUpdate_1_output;


  outputgen: FOR k IN 0 TO 11 GENERATE
    W(k) <= std_logic_vector(W_tmp(k));
  END GENERATE;

END rtl;

