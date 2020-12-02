LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.top_level_pkg.ALL;

ENTITY LMS_Update IS
  PORT( clk_anc                           :   IN    std_logic; --10Khz ANC System Clock
		clk								  :   IN    std_logic; --125Mhz FPGA Clock Pin
        reset                             :   IN    std_logic;
        enb                               :   IN    std_logic;
        X                                 :   IN    std_logic_vector(23 DOWNTO 0);  -- sfix24_En24
        E                                 :   IN    std_logic_vector(23 DOWNTO 0);  -- sfix24_En24
        Adapt                             :   IN    std_logic;
        W                                 :   OUT   vector_of_std_logic_vector24(0 TO 11) := (others => (others => '0')) -- sfix24_En24 [12]
        );
END LMS_Update;

ARCHITECTURE rtl OF LMS_Update IS
	-- Constants
	CONSTANT C_LMS_FILTER_24_STEP_SIZE     : std_logic_vector(23 DOWNTO 0) := "000100000000000000000000";  -- sfix24_En23
	-- Signals
	signal clk_dsp                         : std_logic := '0';
	signal count_reset                     : std_logic := '0';
	signal count                           : unsigned(7 downto 0) := (others => '0'); --mux selector
	SIGNAL input                           : std_logic_vector(23 DOWNTO 0) := (others => '0');  -- sfix24_En24
	SIGNAL error                           : std_logic_vector(23 DOWNTO 0) := (others => '0');  -- sfix24_En24
	SIGNAL input_pipeline                  : vector_of_std_logic_vector24(0 TO 11):= (others => (others => '0'));  -- sfix24_En24 [12]
	SIGNAL input_pipeline_tmp              : vector_of_std_logic_vector24(1 TO 11):= (others => (others => '0'));  -- sfix24_En24 [11]
	SIGNAL weights_pipeline                : vector_of_std_logic_vector24(0 TO 11):= (others => (others => '0'));  -- sfix24_En24 [12]
	
	signal mux1_out, mux2_out              : std_logic_vector(23 downto 0) := (others => '0');
	signal mux1_in, mux2_in                : vector_of_std_logic_vector24(0 TO 11):= (others => (others => '0'));
	signal demux1_in                       : std_logic_vector(23 downto 0) := (others => '0');
	signal demux1_out                      : vector_of_std_logic_vector24(0 to 11):= (others => (others => '0'));
BEGIN
	input <= X;
	error <= E;
	
	LMS_UPDATE_REGISTER : PROCESS(clk_anc)
	BEGIN
		IF RISING_EDGE(clk_anc) THEN
			IF RESET = '1' THEN
				input_pipeline_tmp <= (others => (others => '0'));
			ELSIF enb = '1' THEN
				input_pipeline_tmp(2 to 11) <= input_pipeline_tmp(1 to 10);
				input_pipeline_tmp(1) <= input;
				W <= weights_pipeline;
			END IF;
		END IF;
	END PROCESS;
	
	input_pipeline(1 to 11) <= input_pipeline_tmp(1 to 11);
	input_pipeline(0) <= input;
	mux1_in <= weights_pipeline;
    mux2_in <= input_pipeline;
    weights_pipeline <= demux1_out;
	clk_dsp <= clk;
	
--	CLK_DSP_GEN : entity work.clk_div --15Khz drives 150Hz sine
--    generic map(count => 125) port map(clk_in => clk, clk_out => clk_dsp);
	
	MUX_COUNTER : PROCESS(clk_dsp)
	BEGIN
        IF RISING_EDGE(clk_dsp) THEN
            if adapt = '1' then
                mux1_out <= mux1_in(to_integer(count)); --weights mux
                mux2_out <= mux2_in(to_integer(count)); --inputs mux
                demux1_out(to_integer(count)) <= demux1_in;
                if clk_anc = '1' then count <= (others => '0');
                elsif count < 11 then count <= count + 1; end if;
            end if;
        END IF;
	END PROCESS;
	
	DSP_CORE : entity work.Core_LMS_Update
	port map(
        mu         => C_LMS_FILTER_24_STEP_SIZE,
		input      => mux2_out,
		error      => error,
		weight_in  => mux1_out,
		weight_out => demux1_in
	);
END ARCHITECTURE;