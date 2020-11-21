-- Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2020.1 (win64) Build 2902540 Wed May 27 19:54:49 MDT 2020
-- Date        : Thu Nov 19 23:36:58 2020
-- Host        : DESKTOP-2V0TF99 running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               c:/Vivado_Projects/ANC_System/ANC_System.srcs/sources_1/ip/ila_2/ila_2_stub.vhdl
-- Design      : ila_2
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z020clg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ila_2 is
  Port ( 
    clk : in STD_LOGIC;
    probe0 : in STD_LOGIC_VECTOR ( 23 downto 0 );
    probe1 : in STD_LOGIC_VECTOR ( 23 downto 0 );
    probe2 : in STD_LOGIC_VECTOR ( 23 downto 0 );
    probe3 : in STD_LOGIC_VECTOR ( 23 downto 0 );
    probe4 : in STD_LOGIC_VECTOR ( 23 downto 0 );
    probe5 : in STD_LOGIC_VECTOR ( 23 downto 0 );
    probe6 : in STD_LOGIC_VECTOR ( 23 downto 0 );
    probe7 : in STD_LOGIC_VECTOR ( 23 downto 0 );
    probe8 : in STD_LOGIC_VECTOR ( 23 downto 0 );
    probe9 : in STD_LOGIC_VECTOR ( 23 downto 0 );
    probe10 : in STD_LOGIC_VECTOR ( 23 downto 0 );
    probe11 : in STD_LOGIC_VECTOR ( 23 downto 0 );
    probe12 : in STD_LOGIC_VECTOR ( 23 downto 0 );
    probe13 : in STD_LOGIC_VECTOR ( 23 downto 0 );
    probe14 : in STD_LOGIC_VECTOR ( 23 downto 0 );
    probe15 : in STD_LOGIC_VECTOR ( 23 downto 0 );
    probe16 : in STD_LOGIC_VECTOR ( 23 downto 0 );
    probe17 : in STD_LOGIC_VECTOR ( 23 downto 0 );
    probe18 : in STD_LOGIC_VECTOR ( 23 downto 0 );
    probe19 : in STD_LOGIC_VECTOR ( 23 downto 0 );
    probe20 : in STD_LOGIC_VECTOR ( 23 downto 0 );
    probe21 : in STD_LOGIC_VECTOR ( 23 downto 0 );
    probe22 : in STD_LOGIC_VECTOR ( 23 downto 0 );
    probe23 : in STD_LOGIC_VECTOR ( 23 downto 0 )
  );

end ila_2;

architecture stub of ila_2 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk,probe0[23:0],probe1[23:0],probe2[23:0],probe3[23:0],probe4[23:0],probe5[23:0],probe6[23:0],probe7[23:0],probe8[23:0],probe9[23:0],probe10[23:0],probe11[23:0],probe12[23:0],probe13[23:0],probe14[23:0],probe15[23:0],probe16[23:0],probe17[23:0],probe18[23:0],probe19[23:0],probe20[23:0],probe21[23:0],probe22[23:0],probe23[23:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "ila,Vivado 2020.1";
begin
end;
