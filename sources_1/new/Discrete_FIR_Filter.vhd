----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/03/2020 09:19:33 PM
-- Design Name: 
-- Module Name: Discrete_FIR_Filter - Behavioral
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


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.top_level_pkg.ALL;

ENTITY Discrete_FIR_Filter IS
  GENERIC( L : integer := 12 );
  PORT( clk_anc                               :   IN    std_logic;
        clk_dsp : in std_logic;
        reset                             :   IN    std_logic;
        enb                               :   IN    std_logic;
        input                             :   IN    std_logic_vector(23 DOWNTO 0);  -- sfix24_En24
        coeff                             :   IN    vector_of_std_logic_vector24(0 TO L-1);  -- sfix24_En24 [12]
        output                            :   OUT   std_logic_vector(23 DOWNTO 0) := (others => '0') -- sfix24_En24
        );
END Discrete_FIR_Filter;

architecture Behavioral of Discrete_FIR_Filter is
    signal input_signed : signed(23 downto 0) := (others => '0');
    signal input_buffer : vector_of_signed24(0 to L-1) := (others => (others => '0'));
    signal coeff_signed : vector_of_signed24(0 to L-1) := (others => (others => '0'));
    signal output_next : signed(23 downto 0) := (others => '0');
begin
    input_signed <= signed(input);
    
    CONVERT_COEFF : for i in 0 to L-1 generate
	   coeff_signed(i) <= signed(coeff(i));
	end generate;
	
    FIR_FILTER_REGISTER : PROCESS (clk_anc)
	BEGIN
	IF rising_edge(clk_anc) THEN
		IF reset = '1' THEN
			input_buffer <= (OTHERS => (others => '0'));
		ELSIF enb = '1' THEN
			input_buffer(1 to L-1) <= input_buffer(0 to L-2);
			input_buffer(0) <= input_signed;
			
		END IF;
	END IF;
	END PROCESS FIR_FILTER_REGISTER;
    
    CALCULATE_OUTPUT : PROCESS(clk_dsp)
        variable count : unsigned(8 downto 0) := (others => '0');
        variable mux1_out, mux2_out   : signed(23 downto 0) := (others => '0');
		variable mux1_in, mux2_in     : vector_of_signed24(0 TO L-1):= (others => (others => '0'));
		variable mult0                : signed(47 downto 0) := (others => '0');
		variable mult0_cast           : signed(23 downto 0) := (others => '0');
		variable add0                 : signed(23 downto 0) := (others => '0');
    BEGIN
        if rising_edge(clk_dsp) then
            if clk_anc = '1' then
                count := (others => '0');
            elsif count < L then
                mux1_in := coeff_signed;
                mux2_in := input_buffer;
                mux1_out := mux1_in(to_integer(count)); --coeff mux
                mux2_out := mux2_in(to_integer(count)); --inputs mux
                
                mult0 := mux1_out * mux2_out; -- coeff * input
                mult0_cast := mult0(47 downto 24); 
                add0 := add0 + mult0_cast; --accumulate
                output_next <= add0;
                if count < L-1 then count := count + 1; end if;
            else
                output <= std_logic_vector(output_next);
            end if;
        end if;
    END PROCESS;

end Behavioral;
