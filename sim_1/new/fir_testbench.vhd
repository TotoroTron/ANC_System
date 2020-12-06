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
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fir_testbench is
--  Port ( );
end fir_testbench;

architecture Behavioral of fir_testbench is
    signal clk_anc, clk_dsp, reset, enable, ce_out, clk_enable : std_logic := '0';
    signal fir1_in, fir1_out, fir2_in, fir2_out, sine_out: std_logic_vector(23 downto 0);
    signal Coeff : vector_of_std_logic_vector24(0 to 23) := (others => (others => '0'));
    constant t1 : time := 500ns;
    constant t2 : time := 1ns;
    
    signal dbiterra 		: 	std_logic := '0';
	signal dbiterrb			:	std_logic := '0';
	signal douta 			:	std_logic_vector(23 downto 0) := (others => '0');
	signal doutb 			:	std_logic_vector(23 downto 0) := (others => '0');
	signal sbiterra 		:	std_logic := '0';
	signal sbiterrb 		:	std_logic := '0';
	signal addra 			:	std_logic_vector(7 downto 0) := (others => '0');
	signal addrb 			:	std_logic_vector(7 downto 0) := (others => '0');
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
	signal sleep 			:	std_logic := '0';
	signal wea 				:	std_logic_vector(0 downto 0) := "0";
	signal web 				:	std_logic_vector(0 downto 0) := "0";
	signal lms_data_valid	:	std_logic := '0';
begin
    STIMULUS : process
    begin
        enable <= '1'; clk_enable <= '1';
--        for i in 0 to 500 loop
--        wait until rising_edge(clk_anc);
--        end loop;

        wait;
    end process;
    
        Coeff(0) <= X"400000"; -- 0.25
        Coeff(1) <= X"C00000"; -- -0.25
        Coeff(2) <= X"200000"; -- 0.125
        Coeff(3) <= X"E00000"; -- -0.125
    SINE : entity work.sine_generator(amplitude_49)
    port map(
        clk => clk_anc,
        reset => reset,
        clk_enable => clk_enable,
        Out1 => sine_out
    );

    CLOCK_ANC: process
    begin
        clk_anc <= '0';
        wait for t1/2;
        clk_anc <= '1';
        wait for t1/2;
    end process;
    
    CLOCK_DSP: process
    begin
        clk_dsp <= '0';
        wait for t2/2;
        clk_dsp <= '1';
        wait for t2/2;
    end process;
    
    PARALLEL: entity work.Discrete_FIR_Filter_24
    port map(
        clk => clk_anc,
        reset => reset,
        enb => enable,
        Discrete_FIR_Filter_in => fir1_in,
        Discrete_FIR_Filter_coeff => Coeff,
        Discrete_FIR_Filter_out => fir1_out
    );
    fir1_in <= sine_out;
    
    FIR_FILTER : entity work.Discrete_FIR_Filter_FSM
    generic map(L => 24)
    port map(
        clk_anc 	=> clk_anc,
        clk_dsp 	=> clk_dsp,
        reset 		=> reset,
        en			=> enable,
        input		=> fir2_in,
        output		=> fir2_out,
        --ram interface
        addr		=> addrb,
        ram_en		=> enb,
        wr_en		=> web(0),
        data_in		=> doutb,
        data_valid	=> lms_data_valid
    );   
        fir2_in <= sine_out;
        lms_data_valid <= NOT clk_anc;
        
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
        rsta => reset,
        rstb => reset,
        sleep => sleep, --unused
        wea => wea,
        web => web
    );
    -- End of xpm_memory_tdpram_inst instantiation
        
end architecture;
