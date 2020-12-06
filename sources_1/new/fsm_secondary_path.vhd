LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.top_level_pkg.ALL;

Library xpm;
use xpm.vcomponents.all;
entity secondary_path is
    generic(L : integer := 12);
	port(
		clk_anc 	: in std_logic;
		clk_dsp 	: in std_logic;
		reset 		: in std_logic;
		enable 		: in std_logic;
		
		SPE_input 	: in std_logic_vector(23 downto 0); --secondary path estimator input
		SPE_desired : in std_logic_vector(23 downto 0); --secondary path estimator desired
		SPE_adapt	: in std_logic; --secondary path estimator adapt
		
		SPF_input	: in std_logic_vector(23 downto 0); --secondary path filter input
		SPF_output	: out std_logic_vector(23 downto 0) --secondary path filter output
	);
end entity secondary_path;

architecture rtl of secondary_path is

	signal dbiterra 		: 	std_logic := '0';
	signal dbiterrb			:	std_logic := '0';
	signal douta 			:	std_logic_vector(23 downto 0) := (others => '0');
	signal doutb 			:	std_logic_vector(23 downto 0) := (others => '0');
	signal sbiterra 		:	std_logic := '0';
	signal sbiterrb 		:	std_logic := '0';
	signal addra 			:	std_logic_vector(7 downto 0) := (others => '0');
	signal addrb 			:	std_logic_vector(7 downto 0) := (others => '0');
	signal clka 			:	std_logic := '0';
	signal clkb 			:	std_logic := '0';
	signal dina 			:	std_logic_vector(23 downto 0) := (others => '0');
	signal dinb 			:	std_logic_vector(23 downto 0) := (others => '0');
	signal ena 				:	std_logic := '0';
	signal enb 				:	std_logic := '0';
	signal injectdbiterra	:	std_logic := '0';
	signal injectdbiterrb 	:	std_logic := '0';
	signal injectsbiterra 	:	std_logic := '0';
	signal injectsbiterrb 	:	std_logic := '0';
	signal regcea 			:	std_logic := '0';
	signal regceb 			:	std_logic := '0';
	signal rsta 			:	std_logic := '0';
	signal rstb 			:	std_logic := '0';
	signal sleep 			:	std_logic := '0';
	signal wea 				:	std_logic_vector(0 downto 0) := "0";
	signal web 				:	std_logic_vector(0 downto 0) := "0";
	signal lms_data_valid	:	std_logic := '0';
begin

LMS_FILTER : entity work.LMS_Filter_FSM
generic map(L => L)
port map(
	clk_anc 	=> clk_anc,
	clk_dsp 	=> clk_dsp,
	reset 		=> reset,
	en			=> enable,
	input		=> SPE_input,
	desired		=> SPE_desired,
	adapt		=> SPE_adapt,
	--ram interface
	addr		=> addra,
	ram_en		=> ena,
	wr_en		=> wea(0),
	data_in		=> douta,
	data_out	=> dina,
	data_valid	=> lms_data_valid
);

FIR_FILTER : entity work.Discrete_FIR_Filter_FSM
generic map(L => L)
port map(
	clk_anc 	=> clk_anc,
	clk_dsp 	=> clk_dsp,
	reset 		=> reset,
	en			=> enable,
	input		=> SPF_input,
	output		=> SPF_output,
	--ram interface
	addr		=> addrb,
	ram_en		=> enb,
	wr_en		=> web(0),
	data_in		=> doutb,
	data_valid	=> lms_data_valid
);

-- xpm_memory_tdpram: True Dual Port RAM
-- Xilinx Parameterized Macro, version 2019.2
WEIGHTS_STORAGE : xpm_memory_tdpram
generic map (
	ADDR_WIDTH_A => 8, -- DECIMAL
	ADDR_WIDTH_B => 8, -- DECIMAL
	AUTO_SLEEP_TIME => 0, -- DECIMAL
	BYTE_WRITE_WIDTH_A => 24, -- DECIMAL
	BYTE_WRITE_WIDTH_B => 24, -- DECIMAL
	CASCADE_HEIGHT => 0, -- DECIMAL
	CLOCKING_MODE => "common_clock", -- String
	ECC_MODE => "no_ecc", -- String
	MEMORY_INIT_FILE => "none", -- String
	MEMORY_INIT_PARAM => "0", -- String
	MEMORY_OPTIMIZATION => "true", -- String
	MEMORY_PRIMITIVE => "auto", -- String
	MEMORY_SIZE => 768, -- DECIMAL
	MESSAGE_CONTROL => 0, -- DECIMAL
	READ_DATA_WIDTH_A => 24, -- DECIMAL
	READ_DATA_WIDTH_B => 24, -- DECIMAL
	READ_LATENCY_A => 1, -- DECIMAL
	READ_LATENCY_B => 1, -- DECIMAL
	READ_RESET_VALUE_A => "0", -- String
	READ_RESET_VALUE_B => "0", -- String
	RST_MODE_A => "SYNC", -- String
	RST_MODE_B => "SYNC", -- String
	SIM_ASSERT_CHK => 0, -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
	USE_EMBEDDED_CONSTRAINT => 0, -- DECIMAL
	USE_MEM_INIT => 1, -- DECIMAL
	WAKEUP_TIME => "disable_sleep", -- String
	WRITE_DATA_WIDTH_A => 24, -- DECIMAL
	WRITE_DATA_WIDTH_B => 24, -- DECIMAL
	WRITE_MODE_A => "no_change", -- String
	WRITE_MODE_B => "no_change" -- String
 )
port map (
	dbiterra => dbiterra, --unused
	dbiterrb => dbiterrb, --unused
	douta => douta,
	doutb => doutb,
	sbiterra => sbiterra, --unused
	sbiterrb => sbiterrb, --unused
	addra => addra,
	addrb => addrb,
	clka => clk_dsp,
	clkb => clk_dsp,
	dina => dina,
	dinb => dinb, --unused
	ena => ena,
	enb => enb,
	injectdbiterra => injectdbiterra, --unused
	injectdbiterrb => injectdbiterrb, --unused
	injectsbiterra => injectsbiterra, --unused
	injectsbiterrb => injectsbiterrb, --unused
	regcea => regcea, --unused
	regceb => regceb, --unused
	rsta => rsta,
	rstb => rstb,
	sleep => sleep, --unused
	wea => wea,
	web => web
);
-- End of xpm_memory_tdpram_inst instantiation
	
end architecture;