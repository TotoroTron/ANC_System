-- -------------------------------------------------------------
-- 
-- File Name: hdl_prj\hdlsrc\untitled3\nlmsUpdateSystem_pkg.vhd
-- Created: 2020-10-17 22:41:18
-- 
-- Generated by MATLAB 9.7 and HDL Coder 3.15
-- 
-- -------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

PACKAGE top_level_pkg IS
    TYPE vector_of_std_logic_vector24 IS ARRAY (NATURAL RANGE <>) OF std_logic_vector(23 DOWNTO 0);
    TYPE vector_of_signed24 IS ARRAY (NATURAL RANGE <>) OF signed(23 DOWNTO 0);
    TYPE vector_of_signed48 IS ARRAY (NATURAL RANGE <>) OF signed(47 DOWNTO 0);
    TYPE vector_of_signed46 IS ARRAY (NATURAL RANGE <>) OF signed(45 DOWNTO 0);
    TYPE vector_of_signed49 IS ARRAY (NATURAL RANGE <>) OF signed(48 DOWNTO 0);
    TYPE vector_of_signed53 IS ARRAY (NATURAL RANGE <>) OF signed(52 DOWNTO 0);
    TYPE vector_of_signed77 IS ARRAY (NATURAL RANGE <>) OF signed(76 DOWNTO 0);
    TYPE vector_of_signed32 IS ARRAY (NATURAL RANGE <>) OF signed(31 DOWNTO 0);
    TYPE vector_of_signed72 IS ARRAY (NATURAL RANGE <>) OF signed(31 DOWNTO 0);
    TYPE vector_of_signed73 IS ARRAY (NATURAL RANGE <>) OF signed(31 DOWNTO 0);
    
    COMPONENT ILA_0
        PORT(
            CLK         : IN STD_LOGIC;
            PROBE0      : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
            PROBE1      : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
            PROBE2      : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
            PROBE3      : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
            PROBE4      : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
            PROBE5      : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
            PROBE6      : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
            PROBE7      : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
            PROBE8      : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
            PROBE9      : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
            PROBE10     : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
            PROBE11     : IN STD_LOGIC_VECTOR(23 DOWNTO 0)
        );
    END COMPONENT;
    COMPONENT ILA_1
        PORT(
            CLK         : IN STD_LOGIC;
            PROBE0      : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
            PROBE1      : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
            PROBE2      : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
            PROBE3      : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
            PROBE4      : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
            PROBE5      : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
            PROBE6      : IN STD_LOGIC_VECTOR(23 DOWNTO 0)
        );
    END COMPONENT;
    component clk_wiz_0
        port(
            clk_in1 : in std_logic;
            clk_out1 : out std_logic
        );
    end component;
END top_level_pkg;

