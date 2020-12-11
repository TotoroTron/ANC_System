library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clk_div is
    generic (count : positive range 2 to positive'high); --count = (clk_in freq)/(clk_out freq) 
    port (clk_in : in std_logic; clk_out : out std_logic);
end clk_div;

architecture Behavioral of clk_div is
    signal counter : natural range 0 to count := 0;
    signal clk_tmp : std_logic := '0';
begin
    process(clk_in)
    begin
        if rising_edge(clk_in) then
            if counter = count/2 then
                clk_tmp <= NOT clk_tmp;
                counter <= 0;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;
    clk_out <= clk_tmp;
end Behavioral;

architecture short_pulse of clk_div is
begin
    process(clk_in)
        variable counter : integer range 0 to count := 0;
    begin
        if rising_edge(clk_in) then
            if counter = 0 then
                clk_out <= '1';
                counter := counter + 1;
            elsif counter = count-1 then
                clk_out <= '0';
                counter := 0;
            else
                clk_out <= '0';
                counter := counter + 1;
            end if;
        end if;
    end process;

end short_pulse;
