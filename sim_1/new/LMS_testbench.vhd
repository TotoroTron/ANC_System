----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/18/2020 12:40:22 PM
-- Design Name: 
-- Module Name: fir_testbench - Behavioral
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
USE IEEE.numeric_std.ALL;
USE work.anc_package.ALL;

Library xpm;
use xpm.vcomponents.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity LMS_testbench is
--  Port ( );
end LMS_testbench;

architecture Behavioral of LMS_testbench is
    signal clk, clk_5Mhz : std_logic := '0';
    signal clk_dsp : std_logic := '0';
    signal clk_anc: std_logic := '0';
    signal clk_ila : std_logic := '0';
    signal clk_sine : std_logic := '0';
    signal sine_en : std_logic := '0';
    signal reset : std_logic := '0';
    signal clk_enable: std_logic := '0';
    signal adapt: std_logic := '0';
    signal enable: std_logic := '0';
    signal clk_div_out : std_logic := '0';
    signal clk_41Khz : std_logic:='0';
    signal sine_out, sine_out_ds, rand_out, rand_amp : std_logic_vector(23 downto 0) := (others => '0');
    signal count : unsigned(8 downto 0) := (others => '0');
    
    constant t1 : time := 8ns;
    
    CONSTANT L : integer := 24;
    CONSTANT W : integer := 1;
    CONSTANT R : integer := L/W; --length/width ratio
    
    signal LMS_Coeff : vector_of_std_logic_vector24(0 to 23) := (others => (others => '0'));
    signal FIR_Coeff : vector_of_std_logic_vector24(0 to 23) := (others => (others => '0'));
    
    signal fir_out : std_logic_vector(23 downto 0) := (others => '0');
    signal tmp : std_logic_vector(23 downto 0) := (others => '0');
    
    signal dbiterra 		: 	std_logic := '0';
	signal dbiterrb			:	std_logic := '0';
	signal douta 			:	vector_of_std_logic_vector24(0 to W-1) := (others => (others => '0'));
	signal doutb 			:	vector_of_std_logic_vector24(0 to W-1) := (others => (others => '0'));
	signal sbiterra 		:	std_logic := '0';
	signal sbiterrb 		:	std_logic := '0';
	signal addra 			:	std_logic_vector(5 downto 0) := (others => '0');
	signal addrb 			:	std_logic_vector(5 downto 0) := (others => '0');
	signal dina 			:	vector_of_std_logic_vector24(0 to W-1) := (others => (others => '0'));
	signal dinb 			:	vector_of_std_logic_vector24(0 to W-1) := (others => (others => '0'));
	signal ena 				:	std_logic := '0';
	signal enb 				:	std_logic := '0';
	signal injectdbiterra	:	std_logic := '0';
	signal injectdbiterrb 	:	std_logic := '0';
	signal injectsbiterra 	:	std_logic := '0';
	signal injectsbiterrb 	:	std_logic := '0';
	signal regcea 			:	std_logic := '0';
	signal regceb 			:	std_logic := '0';
	signal sleep 			:	std_logic := '0';
	signal wea 				:	std_logic_vector(0 downto 0) := "0";
	signal web 				:	std_logic_vector(0 downto 0) := "0";
	signal leak : signed(24 downto 0) := '0' & X"FFFF80";
	signal input : signed(23 downto 0) := ('0','1',others => '0');
	signal prod : signed(49 downto 0);
	signal prod_cast : signed(23 downto 0);
begin
    prod <= leak * resize(input,25);
    prod_cast <= prod(47 downto 24);
    CLOCK_ANC : process
    begin
        clk <= '0';
        wait for t1/2;
        clk <= '1';
        wait for t1/2;
    end process;

    SINE_WAVE_150 : entity work.sine_generator(amplitude_25) --150Hz sine output, 1K sample period
    port map(clk => clk_sine, reset => reset, clk_enable => sine_en, Out1 => sine_out);
    SINE_en <= '1';
    SINE_BUFFER : process(clk_anc) begin
        if rising_edge(clk_anc) then
            sine_out_ds <= sine_out;
        end if;
    end process;
    PMOD_CLK : clk_wiz_0
    port map(clk_in1 => clk, clk_out1 => clk_5Mhz);
    COUNTER : process(clk_5Mhz)begin
        if rising_edge(clk_5Mhz) then
            count <= count + 1;
        end if;
    end process;
    clk_dsp <= clk_5Mhz;
    clk_anc <= count(8);
    CLK_GEN_41Khz : entity work.clk_div --15Khz drives 150Hz sine
    generic map(count => 834) port map(clk_in => clk, clk_out => clk_sine);
    
    reset <= '0'; clk_enable <= '1';
    
    FIR_FILTER : entity work.Discrete_FIR_Filter_24
    port map(
        clk => clk_anc,
        reset => reset,
        enb => clk_enable,
        Discrete_FIR_Filter_In => sine_out_ds,
        Discrete_FIR_Filter_Coeff => FIR_Coeff,
        Discrete_FIR_Filter_Out => fir_out
    );
        FIR_Coeff(10) <= X"400000";
        FIR_Coeff(11) <= X"400000";
        
    LMS_FILTER_1 : entity work.LMS_Filter_24
    port map(
        clk => clk_anc,
        reset => reset,
        clk_enable => clk_enable,
        input => fir_out,
        desired => sine_out_ds,
        adapt => adapt,
        weights => LMS_Coeff
    );
        adapt <= '1';
    
    LMS_FILTER_2 : entity work.LMS_Filter_FSM 
	generic map(L => L, W => W)
	port map ( 
		clk_anc 	         => clk_anc,      
		clk_dsp		         => clk_dsp,      
		clk_ila              => clk_ila,
        reset 		         => reset,      
        en   		         => clk_enable,      
        input 		         => fir_out,      
        desired		         => sine_out_ds,      
        Adapt                => adapt,      
		--MEMORY INTERFACE
		wt_addr 		         => addra,      
		wt_ram_en 		         => ena,      
		wt_wr_en 		         => wea(0),      
		wt_data_in 	         => douta,      
		wt_data_out 	         => dina  
    );
        --lms_data_valid <= NOT clk_anc;

     --xpm_memory_tdpram: True Dual Port RAM
     --Xilinx Parameterized Macro, version 2019.2
    GEN_WEIGHTS_STORAGE : for i in 0 to W-1 generate
        WEIGHTS_STORAGE : xpm_memory_tdpram
        generic map (
            ADDR_WIDTH_A => 6, -- DECIMAL
            ADDR_WIDTH_B => 6, -- DECIMAL
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
            MEMORY_SIZE => 1536, -- DECIMAL (measured in bits)
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
            douta => douta(i),
            doutb => doutb(i),
            sbiterra => sbiterra, --unused
            sbiterrb => sbiterrb, --unused
            addra => addra,
            addrb => addrb,
            clka => clk_dsp,
            clkb => clk_dsp,
            dina => dina(i),
            dinb => dinb(i), --unused
            ena => ena,
            enb => enb,
            injectdbiterra => injectdbiterra, --unused
            injectdbiterrb => injectdbiterrb, --unused
            injectsbiterra => injectsbiterra, --unused
            injectsbiterrb => injectsbiterrb, --unused
            regcea => regcea, --unused
            regceb => regceb, --unused
            rsta => reset,
            rstb => reset,
            sleep => sleep, --unused
            wea => wea,
            web => web
        );
        -- End of xpm_memory_tdpram_inst instantiation
    end generate GEN_WEIGHTS_STORAGE;

end Behavioral;
