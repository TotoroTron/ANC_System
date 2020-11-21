-- Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2020.1 (win64) Build 2902540 Wed May 27 19:54:49 MDT 2020
-- Date        : Wed Nov 18 18:14:48 2020
-- Host        : DESKTOP-2V0TF99 running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub -rename_top ila_3 -prefix
--               ila_3_ ila_1_stub.vhdl
-- Design      : ila_1
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z020clg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ila_3 is
  Port ( 
    clk : in STD_LOGIC;
    probe0 : in STD_LOGIC_VECTOR ( 23 downto 0 );
    probe1 : in STD_LOGIC_VECTOR ( 23 downto 0 );
    probe2 : in STD_LOGIC_VECTOR ( 23 downto 0 );
    probe3 : in STD_LOGIC_VECTOR ( 23 downto 0 );
    probe4 : in STD_LOGIC_VECTOR ( 23 downto 0 );
    probe5 : in STD_LOGIC_VECTOR ( 23 downto 0 );
    probe6 : in STD_LOGIC_VECTOR ( 23 downto 0 )
  );

end ila_3;

architecture stub of ila_3 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk,probe0[23:0],probe1[23:0],probe2[23:0],probe3[23:0],probe4[23:0],probe5[23:0],probe6[23:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "ila,Vivado 2020.1";
begin
end;
