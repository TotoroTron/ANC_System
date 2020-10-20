library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity pmod_i2s2 is
	port(
		--system clock and reset
		clk : in std_logic; --freq = 22.5792 Mhz, period = 
		reset : in std_logic;
		
		--parallelized data
		data_mic : out std_logic_vector(23 downto 0); --corr. line in
		data_spkr : in std_logic_vector(23 downto 0); --corr. line out
		
		--line out
		tx_mclk : out std_logic;
		tx_lrck : out std_logic;
		tx_sclk : out std_logic;
		tx_data : out std_logic;
		
		--line in
		rx_mclk : out std_logic;
		rx_lrck : out std_logic;
		rx_sclk : out std_logic;
		rx_data : in std_logic
	);
end entity pmod_i2s2;

architecture behavioral of pmod_i2s2 is
	signal tx_shift_reg : std_logic_vector(23 downto 0) := (others => '0'); --data bits are shifted in here 1 by 1 through tx_data
	signal rx_shift_reg : std_logic_vector(23 downto 0) := (others => '0'); --data bits are shifted out of here 1 by 1 to rx_data

	signal mclk, sclk, lrck : std_logic := '0';
	signal count : unsigned(8 downto 0) := (others => '0');
begin
  
    tx_mclk <= mclk; rx_mclk <= mclk;
    tx_lrck <= lrck; rx_lrck <= lrck;
    tx_sclk <= sclk; rx_sclk <= sclk;
    
    --Speed Mode : Single-Speed Mode
    --MCLK/LRCLK RATIO : 256x
    --SCLK/LRCLK RATIO : 64x
    --Input Sample Rate Range : 43-54 Khz
    
    
    --LRCK : 88.2 Khz
    --MCLK : 22.5792 Mhz
    --SCLK = 64 * LRCK = 5.6448 Mhz
    
    lrck <= count(8); -- 100000000 : 2^8 = 256
    --MCLK/LRCK = 256
    sclk <= count(2); -- 000000100 : 2^2 = 4
    --MCLK/SCLK = 4, therefore, SCLK/LRCK = 64
    mclk <= clk; --22.5792 Mhz

    COUNTER : process(clk)
    begin
        if rising_edge(clk) then
            count <= count + 1;
        end if;
    end process;
	
    SHIFT_REG : process(sclk, lrck)
    begin
        
        if falling_edge(sclk) then    
            tx_shift_reg(23 downto 1) <= tx_shift_reg(22 downto 0); --shift left
            tx_data <= tx_shift_reg(0);
            
            rx_shift_reg(22 downto 0) <= rx_shift_reg(23 downto 1); --shift right
            rx_shift_reg(0) <= rx_data;
        end if;
        if lrck'event then
            data_mic <= rx_shift_reg;
            tx_shift_reg <= data_spkr;
        end if;
    end process;
end architecture;