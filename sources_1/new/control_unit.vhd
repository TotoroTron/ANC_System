----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/23/2020 01:35:29 PM
-- Design Name: 
-- Module Name: control_unit - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
USE work.anc_package.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity control_unit is
    port(
        clk_anc : in std_logic;
        reset : in std_logic;
        adapt : in std_logic;
        ctrl : out std_logic_vector(31 downto 0)
    );
end control_unit;

architecture Behavioral of control_unit is
    signal count : unsigned(23 downto 0) := (others => '0');
    signal training_mode: std_logic;
    signal sine_en      : std_logic;
    signal rand_en      : std_logic;
    signal SPF_en       : std_logic;
    signal SPA_en       : std_logic;
    signal SPA_adapt    : std_logic;
    signal PPF_en       : std_logic;
    signal PPA_en       : std_logic;
    signal PPA_adapt    : std_logic;
    signal AFF_en       : std_logic;
    signal AFA_en       : std_logic;
    signal AFA_adapt    : std_logic;
begin
    
    ctrl(0) <= training_mode;
    ctrl(1) <= sine_en; --sine noise enable
    ctrl(2) <= rand_en; --training noise enable
    ctrl(3) <= SPF_en; --secondary path filter enable
    ctrl(4) <= SPA_en; --secondary path algorithm enable
    ctrl(5) <= SPA_adapt; --secondary path algorithm adapt
    ctrl(6) <= PPF_en; --primary path filter enable
    ctrl(7) <= PPA_en; --primary path algorithm enable
    ctrl(8) <= PPA_adapt; --primary path algorithm adapt
    ctrl(9) <= AFF_en; --acoustic feedback filter enable
    ctrl(10)<= AFA_en; --acoustic feedback algorithm enable
    ctrl(11)<= AFA_adapt; --acoustic feedback algorithm adapt

    COUNTER : process(clk_anc)
    begin
        if rising_edge(clk_anc) then
            if reset = '1' then
            count <= (others => '0');
            else
                if count < 1000000 then
                count <= count + 1;
                end if;
            end if;
        end if;
    end process;
    
    TRAIN_ADAPT_SEQUENCE : process(count, adapt)
    begin
        sine_en <= '0'; rand_en <= '0';
        SPA_en <= '0'; SPF_en <= '0'; SPA_adapt <= '0';
        AFA_en <= '0'; AFF_en <= '0'; AFA_adapt <= '0';
        PPA_en <= '0'; PPF_en <= '0'; PPA_adapt <= '0';
        training_mode <= '0';
        
        if count < 200000 then
            rand_en <= '1';
            training_mode <= '1';
            if count > 625 then
                SPA_en <= '1';
                SPA_adapt <= '1';
                AFA_en <= '1';
                AFA_adapt <= '1';
            end if;
        else
            sine_en <= '1';
            SPF_en <= adapt;
            AFF_en <= adapt;
            PPA_en <= adapt;
            PPF_en <= adapt;
            PPA_adapt <= adapt;
        end if;
    end process;

end Behavioral;
