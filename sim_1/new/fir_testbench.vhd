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
USE work.top_level_pkg.ALL;

Library xpm;
use xpm.vcomponents.all;

entity fir_testbench is
--  Port ( );
end fir_testbench;

architecture Behavioral of fir_testbench is
    signal clk : std_logic := '0';
    constant t_clk : time := 10ns;
    signal clk_anc: std_logic := '0';
    signal clk_dsp : std_logic := '0';
    signal clk_ila : std_logic := '0';
    signal clk_sine : std_logic := '0';
    signal clk_5Mhz : std_logic := '0';
    signal sine_en : std_logic := '0';
    signal reset : std_logic := '0';
    signal enable : std_logic := '0';
    signal clk_enable : std_logic := '0';
    signal fir1_in, fir1_out, fir2_in, fir2_out: std_logic_vector(23 downto 0);
    signal sine_out, sine_out_ds : std_logic_vector(23 downto 0) := (others => '0');
    signal Coeff : vector_of_std_logic_vector24(0 to 11) := (others => (others => '0'));
    signal count : unsigned(8 downto 0) := (others => '0');
    CONSTANT L : integer    := 12;
    CONSTANT W : integer    := 1; --width
	CONSTANT R : integer    := L/W; --length/width ratio
    signal dbiterra 		: 	std_logic := '0';
	signal dbiterrb			:	std_logic := '0';
	signal douta1 			:	vector_of_std_logic_vector24(0 to W-1) := (others => (others => '0'));
	signal doutb1 			:	vector_of_std_logic_vector24(0 to W-1) := (others => (others => '0'));
	signal douta2 			:	vector_of_std_logic_vector24(0 to W-1) := (others => (others => '0'));
	signal doutb2 			:	vector_of_std_logic_vector24(0 to W-1) := (others => (others => '0'));
	signal sbiterra 		:	std_logic := '0';
	signal sbiterrb 		:	std_logic := '0';
	signal addra1 			:	std_logic_vector(7 downto 0) := (others => '0');
	signal addrb1 			:	std_logic_vector(7 downto 0) := (others => '0');
    signal addra2 			:	std_logic_vector(7 downto 0) := (others => '0');
	signal addrb2 			:	std_logic_vector(7 downto 0) := (others => '0');
	signal dina1 			:	vector_of_std_logic_vector24(0 to W-1) := (others => (others => '0'));
	signal dinb1 			:	vector_of_std_logic_vector24(0 to W-1) := (others => (others => '0'));
    signal dina2 			:	vector_of_std_logic_vector24(0 to W-1) := (others => (others => '0'));
	signal dinb2 			:	vector_of_std_logic_vector24(0 to W-1) := (others => (others => '0'));
	signal ena1 			:	std_logic := '0';
	signal enb1 			:	std_logic := '0';
    signal ena2 			:	std_logic := '0';
	signal enb2 			:	std_logic := '0';
	signal injectdbiterra	:	std_logic := '0';
	signal injectdbiterrb 	:	std_logic := '0';
	signal injectsbiterra 	:	std_logic := '0';
	signal injectsbiterrb 	:	std_logic := '0';
	signal regcea 			:	std_logic := '0';
	signal regceb 			:	std_logic := '0';
	signal sleep 			:	std_logic := '0';
	signal wea1 			:	std_logic_vector(0 downto 0) := "0";
	signal web1 			:	std_logic_vector(0 downto 0) := "0";
    signal wea2 			:	std_logic_vector(0 downto 0) := "0";
	signal web2 			:	std_logic_vector(0 downto 0) := "0";
	signal lms_data_valid1	:	std_logic := '0';
    signal lms_data_valid2	:	std_logic := '0';
begin

        Coeff(0) <= X"100000"; -- 0.25
        Coeff(1) <= X"200000"; -- -0.25
        Coeff(2) <= X"300000"; -- 0.125
        Coeff(3) <= X"400000"; -- 0.25
        Coeff(4) <= X"500000"; -- -0.25
        Coeff(5) <= X"600000"; -- 0.125
        Coeff(6) <= X"700000"; -- 0.25
        Coeff(7) <= X"800000"; -- -0.25
        Coeff(8) <= X"900000"; -- 0.125
        Coeff(9) <= X"a00000"; -- 0.25
        Coeff(10) <= X"b00000"; -- -0.25
        Coeff(11) <= X"c00000"; -- 0.125

    CLOCK: process
    begin
        clk <= '0';
        wait for t_clk/2;
        clk <= '1';
        wait for t_clk/2;
    end process;
    
    STIMULUS : PROCESS
    BEGIN
        ENABLE <= '0';
        FOR I IN 1 TO 4 LOOP
        WAIT UNTIL RISING_EDGE(CLK_ANC);
        END LOOP;
        ENABLE <= '1';
        FOR I IN 1 TO 4 LOOP
        WAIT UNTIL RISING_EDGE(CLK_ANC);
        END LOOP;
        ENABLE <= '0';        
        WAIT;
    END PROCESS;
    
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
    
    PARALLEL_1 : entity work.Discrete_FIR_Filter_12
    port map(
        clk => clk_anc,
        reset => reset,
        enb => enable,
        Discrete_FIR_Filter_in => fir1_in,
        Discrete_FIR_Filter_coeff => Coeff,
        Discrete_FIR_Filter_out => fir1_out
    );
        fir1_in <= sine_out_ds;

    PIPELINE_1 : entity work.Discrete_FIR_Filter_FSM
    generic map(L => L, W => W)
    port map(
        clk_anc 	=> clk_anc,
        clk_dsp 	=> clk_dsp,
        clk_ila     => clk_ila,
        reset 		=> reset,
        en			=> enable,
        input		=> fir2_in,
        output		=> fir2_out,
        --ram interface
        addr		=> addrb1,
        ram_en		=> enb1,
        wr_en		=> web1(0),
        data_in		=> doutb1,
        data_valid	=> lms_data_valid1
    );   
        fir2_in <= sine_out_ds;  
        
    -- xpm_memory_tdpram: True Dual Port RAM
    -- Xilinx Parameterized Macro, version 2019.2
    GEN_WEIGHTS_STORAGE : for i in 0 to W-1 generate
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
            MEMORY_INIT_FILE => "ram_init_0.mem", -- String
            MEMORY_INIT_PARAM => "0", -- String
            MEMORY_OPTIMIZATION => "true", -- String
            MEMORY_PRIMITIVE => "auto", -- String
            MEMORY_SIZE => 6144, -- DECIMAL (measured in bits)
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
            douta => douta1(i),
            doutb => doutb1(i),
            sbiterra => sbiterra, --unused
            sbiterrb => sbiterrb, --unused
            addra => addra1,
            addrb => addrb1,
            clka => clk_dsp,
            clkb => clk_dsp,
            dina => dina1(i),
            dinb => dinb1(i), --unused
            ena => ena1,
            enb => enb1,
            injectdbiterra => injectdbiterra, --unused
            injectdbiterrb => injectdbiterrb, --unused
            injectsbiterra => injectsbiterra, --unused
            injectsbiterrb => injectsbiterrb, --unused
            regcea => regcea, --unused
            regceb => regceb, --unused
            rsta => reset,
            rstb => reset,
            sleep => sleep, --unused
            wea => wea1,
            web => web1
        );
        -- End of xpm_memory_tdpram_inst instantiation
    end generate; 
end architecture;
