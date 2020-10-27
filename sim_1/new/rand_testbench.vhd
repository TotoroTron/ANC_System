LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use work.top_level_pkg.all;
 
ENTITY PRBS_testbench IS
END PRBS_testbench;
 
ARCHITECTURE behavior OF PRBS_testbench IS 
    COMPONENT PRBS PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         ce : IN  std_logic;
         rand : OUT  std_logic_vector(23 downto 0)
    ); END COMPONENT;
    signal clk, clk2 : std_logic;
    signal reset : std_logic;
    signal ce : std_logic;
    signal rand : std_logic_vector(23 downto 0);
    constant clk_period : time := 100 ns;
    constant clk_period2 : time := 10 ns;
    signal enb, fir_valid_in, fir_valid_out : std_logic := '0';
    signal fir_out : std_logic_vector(23 downto 0);
    signal lms_ce_out : std_logic := '0';
    signal weights, const_coeff : vector_of_std_logic_vector24(0 to 11) := (others => (others => '0'));
    type REGISTER_PIPE is array (0 to 18) of std_logic_vector(23 downto 0);
    signal data_pipeline : REGISTER_PIPE := (others => (others => '0'));
    signal rand_delayed : std_logic_vector(23 downto 0) := (others => '0');
BEGIN

    STIMULUS : process
    begin
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        enb <= '1';     fir_valid_in <= '1';
    end process;

    reset <= '0';
    LMS: entity work.LMSFilter
    port map(
        clk => clk,
        reset => reset,
        clk_enable => fir_valid_out,
        In1 => rand_delayed, --input
        In2 => fir_out, --desired
        ce_out => lms_ce_out,
        Out3 => weights
    );
    
    const_coeff <= (X"011111", X"011111", X"000000", X"000000", X"000000", X"000000", X"000000", X"000000", X"000000",X"000000",X"000000",X"000000");

    data_pipeline(0) <= rand;
    rand_delayed <= data_pipeline(18);
    DATA_REGISTER : process(clk)
    begin
        if rising_edge(clk) then
            data_pipeline(1 to 18) <= data_pipeline(0 to 17);
        end if;
    end process;
    
    ce <= '1';
    UUT: PRBS PORT MAP (
        clk => clk2,
        rst => reset,
        ce => ce,
        rand => rand
    );
    
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;
    clk_process2 :process
    begin
        clk2 <= '0';
        wait for clk_period2/2;
        clk2 <= '1';
        wait for clk_period2/2;
    end process;

END;