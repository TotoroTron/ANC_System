-- -------------------------------------------------------------
-- 
-- File Name: hdl_prj\hdlsrc\untitled3\nlmsUpdate.vhd
-- Created: 2020-10-17 22:41:18
-- 
-- Generated by MATLAB 9.7 and HDL Coder 3.15
-- 
-- -------------------------------------------------------------


-- -------------------------------------------------------------
-- 
-- Module: nlmsUpdate
-- Source Path: untitled3/nlmsUpdateSystem/nlmsUpdate
-- Hierarchy Level: 1
-- 
-- -------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.top_level_pkg.ALL;

ENTITY nlmsUpdate IS
  PORT( clk                               :   IN    std_logic;
        reset                             :   IN    std_logic;
        enb                               :   IN    std_logic;
        X                                 :   IN    std_logic_vector(23 DOWNTO 0);  -- sfix24
        E                                 :   IN    std_logic_vector(23 DOWNTO 0);  -- sfix24
        Adapt                             :   IN    std_logic;
        W                                 :   OUT   vector_of_std_logic_vector24(0 TO 11)  -- sfix24_En23 [12]
        );
END nlmsUpdate;


ARCHITECTURE rtl OF nlmsUpdate IS

  -- Constants
  CONSTANT C_divbyzero_p                  : signed(48 DOWNTO 0) := 
    signed'("0111111111111111111111111111111111111111111111111");  -- sfix49
  CONSTANT C_divbyzero_n                  : signed(48 DOWNTO 0) := 
    signed'("1000000000000000000000000000000000000000000000000");  -- sfix49

  -- Signals
  SIGNAL X_signed                         : signed(23 DOWNTO 0);  -- sfix24
  SIGNAL E_signed                         : signed(23 DOWNTO 0);  -- sfix24
  SIGNAL W_tmp                            : vector_of_signed24(0 TO 11);  -- sfix24_En23 [12]
  SIGNAL xBuffer                          : vector_of_signed24(0 TO 11);  -- sfix24 [12]
  SIGNAL wBuffer                          : vector_of_signed24(0 TO 11);  -- sfix24 [12]
  SIGNAL xBuffer_next                     : vector_of_signed24(0 TO 11);  -- sfix24 [12]
  SIGNAL wBuffer_next                     : vector_of_signed24(0 TO 11);  -- sfix24_En23 [12]

BEGIN
  X_signed <= signed(X);

  E_signed <= signed(E);

  nlmsUpdate_1_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      xBuffer <= (OTHERS => to_signed(16#000000#, 24));
      wBuffer <= (OTHERS => to_signed(16#000000#, 24));
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb = '1' THEN
        xBuffer <= xBuffer_next;
        wBuffer <= wBuffer_next;
      END IF;
    END IF;
  END PROCESS nlmsUpdate_1_process;

  nlmsUpdate_1_output : PROCESS (Adapt, E_signed, X_signed, wBuffer, xBuffer)
    VARIABLE xEnergy : signed(51 DOWNTO 0);
    VARIABLE emu : signed(23 DOWNTO 0);
    VARIABLE xbufdivengy : signed(51 DOWNTO 0);
    VARIABLE w_adj : signed(75 DOWNTO 0);
    VARIABLE hfi : signed(47 DOWNTO 0);
    VARIABLE c : vector_of_signed48(0 TO 11);
    VARIABLE xBuffer_temp : vector_of_signed24(0 TO 11);
    VARIABLE wBuffer_temp : vector_of_signed24(0 TO 11);
    VARIABLE div_temp : vector_of_signed46(0 TO 11);
    VARIABLE div_temp_0 : vector_of_signed49(0 TO 11);
    VARIABLE add_temp : vector_of_signed53(0 TO 10);
    VARIABLE cast : vector_of_signed46(0 TO 11);
    VARIABLE slice_cast : vector_of_signed49(0 TO 11);
    VARIABLE slice_cast_0 : vector_of_signed49(0 TO 11);
    VARIABLE cast_0 : vector_of_signed49(0 TO 11);
    VARIABLE add_cast : vector_of_signed77(0 TO 11);
    VARIABLE add_cast_0 : vector_of_signed77(0 TO 11);
    VARIABLE add_temp_0 : vector_of_signed77(0 TO 11);
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
    xBuffer_temp(1 TO 11) := xBuffer(0 TO 10);
    xBuffer_temp(0) := X_signed;

    FOR t_0 IN 0 TO 11 LOOP
      c(t_0) := xBuffer_temp(t_0) * xBuffer_temp(t_0);
    END LOOP;

    xEnergy := resize(c(0), 52);

    FOR k IN 0 TO 10 LOOP
      add_temp(k) := resize(xEnergy, 53) + resize(c(k + 1), 53);
      IF (add_temp(k)(52) = '0') AND (add_temp(k)(51) /= '0') THEN 
        xEnergy := X"7FFFFFFFFFFFF";
      ELSIF (add_temp(k)(52) = '1') AND (add_temp(k)(51) /= '1') THEN 
        xEnergy := X"8000000000000";
      ELSE 
        xEnergy := add_temp(k)(51 DOWNTO 0);
      END IF;
    END LOOP;

    IF Adapt = '1' THEN 

      FOR idx IN 0 TO 11 LOOP
        cast(idx) := E_signed & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0';
        div_temp(idx) := cast(idx) / to_signed(16#400000#, 24);
        IF ((div_temp(idx)(45) = '0') AND (div_temp(idx)(44 DOWNTO 24) /= "000000000000000000000")) OR ((div_temp(idx)(45) = '0') AND (div_temp(idx)(24 DOWNTO 1) = X"7FFFFF")) THEN 
          emu := X"7FFFFF";
        ELSIF (div_temp(idx)(45) = '1') AND (div_temp(idx)(44 DOWNTO 24) /= "111111111111111111111") THEN 
          emu := X"800000";
        ELSE 
          emu := div_temp(idx)(24 DOWNTO 1) + ('0' & div_temp(idx)(0));
        END IF;
        --24 bit, 0 fractional
        --xbufdivengy = fi(xBuffer(idx),1 , 64, 32) / xEnergy; %24 bit / 48 bit
        hfi := xBuffer_temp(idx) & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0';
        IF xEnergy = to_signed(0, 52) THEN 
          IF hfi < to_signed(0, 48) THEN 
            xbufdivengy := signed'(X"8000000000000");
          ELSE 
            xbufdivengy := signed'(X"7FFFFFFFFFFFF");
          END IF;
        ELSE 
          slice_cast(idx) := hfi & '0';
          IF slice_cast(idx)(48) = xEnergy(51) THEN 
            slice_cast_0(idx) := C_divbyzero_p;
          ELSE 
            slice_cast_0(idx) := C_divbyzero_n;
          END IF;
          cast_0(idx) := hfi & '0';
          IF xEnergy = 0 THEN 
            div_temp_0(idx) := slice_cast_0(idx);
          ELSE 
            div_temp_0(idx) := cast_0(idx) / xEnergy;
          END IF;
          xbufdivengy := (resize(div_temp_0(idx)(48 DOWNTO 1), 52)) + ('0' & div_temp_0(idx)(0));
        END IF;
        w_adj := emu * xbufdivengy;
        add_cast(idx) := resize(wBuffer_temp(idx) & '0', 77);
        add_cast_0(idx) := resize(w_adj, 77);
        add_temp_0(idx) := add_cast(idx) + add_cast_0(idx);
        IF ((add_temp_0(idx)(76) = '0') AND (add_temp_0(idx)(75 DOWNTO 24) /= X"0000000000000")) OR ((add_temp_0(idx)(76) = '0') AND (add_temp_0(idx)(24 DOWNTO 1) = X"7FFFFF")) THEN 
          wBuffer_temp(idx) := X"7FFFFF";
        ELSIF (add_temp_0(idx)(76) = '1') AND (add_temp_0(idx)(75 DOWNTO 24) /= X"FFFFFFFFFFFFF") THEN 
          wBuffer_temp(idx) := X"800000";
        ELSE 
          wBuffer_temp(idx) := add_temp_0(idx)(24 DOWNTO 1) + ('0' & add_temp_0(idx)(0));
        END IF;
      END LOOP;

    END IF;
    W_tmp <= wBuffer_temp;
    xBuffer_next <= xBuffer_temp;
    wBuffer_next <= wBuffer_temp;
  END PROCESS nlmsUpdate_1_output;


  outputgen: FOR k1 IN 0 TO 11 GENERATE
    W(k1) <= std_logic_vector(W_tmp(k1));
  END GENERATE;

END rtl;

