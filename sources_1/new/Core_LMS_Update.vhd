LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.top_level_pkg.ALL;

ENTITY Core_LMS_Update IS
	PORT(
		mu : in std_logic_vector(23 downto 0); --step size
		input : in std_logic_vector(23 downto 0);
		error : in std_logic_vector(23 downto 0);
		weight_in : in std_logic_vector(23 downto 0);
		weight_out : out std_logic_vector(23 downto 0)
	);
END Core_LMS_Update;

architecture rtl of Core_LMS_Update is
    signal mu_signed           : signed(23 downto 0) := (others => '0');
	signal input_signed        : signed(23 downto 0) := (others => '0');
	signal error_signed        : signed(23 downto 0) := (others => '0');
	signal weight_in_signed    : signed(23 downto 0) := (others => '0');
	signal mu_err              : signed(47 downto 0) := (others => '0'); --product of mu and error
	signal mu_err_cast         : signed(23 downto 0) := (others => '0'); --LSB truncated mu_err
	signal mult0               : signed(47 downto 0) := (others => '0'); --product of mu_error and weight_in
	signal mult0_cast          : signed(23 downto 0) := (others => '0'); --LSB truncated mult0
	signal add0                : signed(23 downto 0) := (others => '0'); --addition of mult0_cast and input
	--signal add0_cast         : signed(23 downto 0) := (others => '0'); --MSB truncated add0
begin

    mu_signed <= signed(mu);
    input_signed <= signed(input);
    error_signed <= signed(error);
    weight_in_signed <= signed(weight_in);
    
	mu_err <= mu_signed * error_signed;
	mu_err_cast <= mu_err(47 downto 24);
	mult0 <= mu_err_cast * input_signed;
	mult0_cast <= mult0(47 downto 24);
	add0 <= mult0_cast + weight_in_signed;
	
	weight_out <= std_logic_vector(add0);

end architecture;