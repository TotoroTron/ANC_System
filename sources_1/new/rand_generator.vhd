--  ____                        _             _            
-- / ___|  ___  _   _ _ __   __| | __ _  __ _| |_ ___  ___ 
-- \___ \ / _ \| | | | '_ \ / _` |/ _` |/ _` | __/ _ \/ __|
--  ___) | (_) | |_| | | | | (_| | (_| | (_| | ||  __/\__ \
-- |____/ \___/ \__,_|_| |_|\__,_|\__, |\__,_|\__\___||___/
--                                |___/                    
-- ======================================================================
--
--   title:        VHDL module - PRBS.vhd
--
--   project:      PG-Soundgates
--   author:       Hendrik Hangmann, University of Paderborn
--
--   description:  Generates pseudo random bit sequences, as needed for
--                 white noise, implementing "Fibonacci-LFSR"
--
-- ======================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

--use work.soundgates_common_pkg.all;

entity PRBS is
    Generic ( constant levels : integer := 24);
    Port (    clk    : in  STD_LOGIC;
              rst    : in  STD_LOGIC;
              ce     : in  STD_LOGIC;
              rand   : out STD_LOGIC_VECTOR (levels - 1 downto 0));
end PRBS;

architecture Behavioral of PRBS is

	signal seed			   : std_logic_vector (levels-1 downto 0) := (0 => '1', others => '0');
	signal feedback	   : std_logic := '1';
 	--constant polynome		: std_logic_vector (0 to levels-1)     := "10110100000000001011010000000000";
begin

	rand <= seed;

 	process (clk, rst, seed, ce)
	begin
        if (rising_edge(clk)) then
            if (rst = '1') then
                seed <= (0 => '1', others => '0');
            elsif ce = '1' then
                feedback <= feedback xor (seed(5) xor (seed(3) xor (seed(2) xor seed(0))));
            
                seed <= feedback & seed (levels - 1 downto 1);
            end if;
        end if;
	end process;	

end Behavioral;