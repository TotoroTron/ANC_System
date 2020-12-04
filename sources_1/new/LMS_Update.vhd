--worked
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.top_level_pkg.ALL;

ENTITY LMS_Update IS
  GENERIC( L : integer := 12); --length
  PORT( clk_anc                           :   IN    std_logic; --10Khz ANC System Clock
		clk_dsp							  :   IN    std_logic; --125Mhz FPGA Clock Pin
        reset                             :   IN    std_logic;
        enb                               :   IN    std_logic;
        X                                 :   IN    std_logic_vector(23 DOWNTO 0);  -- sfix24_En24
        E                                 :   IN    std_logic_vector(23 DOWNTO 0);  -- sfix24_En24
        Adapt                             :   IN    std_logic;
        W                                 :   OUT   vector_of_std_logic_vector24(0 TO L-1) := (others => (others => '0')) -- sfix24_En24 [12]
        );
END LMS_Update;

ARCHITECTURE Behavioral OF LMS_Update IS
	SIGNAL X_signed                         : signed(23 DOWNTO 0) := (others => '0');  -- sfix24_En24
	SIGNAL E_signed                         : signed(23 DOWNTO 0) := (others => '0');  -- sfix24_En24
	SIGNAL xBuffer                          : vector_of_signed24(0 TO L-1) := (others => (others => '0'));  -- sfix24 [12]
	SIGNAL wBuffer                          : vector_of_signed24(0 TO L-1) := (others => (others => '0'));  -- sfix24 [12]
	SIGNAL wBuffer_next                     : vector_of_signed24(0 TO L-1) := (others => (others => '0'));  -- sfix24_En24 [12]
BEGIN
	
	X_signed <= signed(X);
	E_signed <= signed(E);
	
	LMS_UPDATE_REGISTER : PROCESS (clk_anc)
	BEGIN
	IF rising_edge(clk_anc) THEN
		IF reset = '1' THEN
			xBuffer <= (OTHERS => (others => '0'));
			wBuffer <= (OTHERS => (others => '0'));
		ELSIF enb = '1' THEN
			xBuffer(1 to L-1) <= xBuffer(0 to L-2);
			xBuffer(0) <= X_signed;
			wBuffer <= wBuffer_next;
		END IF;
	END IF;
	END PROCESS LMS_UPDATE_REGISTER;
	
	CALCULATE_WEIGHTS : PROCESS(clk_dsp)
		variable count : unsigned(8 downto 0) := (others => '0');
		variable mux1_in, mux2_in     : vector_of_signed24(0 TO L-1):= (others => (others => '0'));
		variable mux1_out, mux2_out   : signed(23 downto 0) := (others => '0');
		variable demux1_in            : signed(23 downto 0) := (others => '0');
		variable demux1_out           : vector_of_signed24(0 to L-1):= (others => (others => '0'));
		variable mu                   : signed(23 downto 0) := "001000000000000000000000";
		variable mu_err               : signed(47 downto 0) := (others => '0'); --product of mu and error
		variable mu_err_cast          : signed(23 downto 0) := (others => '0'); --LSB truncated mu_err
		variable mult0                : signed(47 downto 0) := (others => '0'); --product of mu_error and weight_in
		variable mult0_cast           : signed(23 downto 0) := (others => '0'); --LSB truncated mult0
		variable add0                 : signed(23 downto 0) := (others => '0'); --addition of mult0_cast and input
	BEGIN
        IF RISING_EDGE(clk_dsp) THEN
            if adapt = '1' then
				if clk_anc = '1' then
					count := (others => '0');
				elsif count < L then
					mux1_in := wBuffer;
					mux2_in := xBuffer;
					mux1_out := mux1_in(to_integer(count)); --weights mux
					mux2_out := mux2_in(to_integer(count)); --inputs mux
					
					mu_err := mu * E_signed;
					mu_err_cast := mu_err(47 downto 24);
					mult0 := mu_err_cast * mux2_out;
					mult0_cast := mult0(47 downto 24);
					add0 := mult0_cast + mux1_out;
									
					demux1_in := add0;
					demux1_out(to_integer(count)) := demux1_in;
					wBuffer_next <= demux1_out;
					if count < L-1 then count := count + 1; end if;
		        else
		            
				end if;
            end if;
        END IF;
	END PROCESS;
	
    OUTPUT_WEIGHTS : for i in 0 to L-1 generate
	   W(i) <= std_logic_vector(wBuffer(i));
	end generate;
	
END ARCHITECTURE;