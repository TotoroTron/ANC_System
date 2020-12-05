
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.top_level_pkg.ALL;


entity lmsUpdate_testbench is
--  Port ( );
end lmsUpdate_testbench;
--
architecture Behavioral of lmsUpdate_testbench is
    signal clk_dsp, clk_anc, reset, clk_enable, adapt, ce_out, enb: std_logic := '0';
    signal sine_out : std_logic_vector(23 downto 0) := (others => '0');
    constant t1 : time := 400ns;
    constant t2 : time := 10ns;
        
    signal LMSU_input, LMSU_error: std_logic_vector(23 downto 0) := (others => '0');
    signal LMSU_en : std_logic := '0';
    
    signal ESP_FilterIn, ESP_FilterOut: std_logic_vector(23 downto 0) := (others => '0');
    signal ESP_Coeff : vector_of_std_logic_vector24(0 to 11) := (others => (others => '0'));
    signal ESP_en : std_logic := '0';
    
    signal SP_FilterIn, SP_FilterOut: std_logic_vector(23 downto 0) := (others => '0');
    signal SP_Coeff : vector_of_std_logic_vector24(0 to 11) := (others => (others => '0'));
    signal SP_en : std_logic := '0';
    
    signal ANC_FilterIn, ANC_FilterOut : std_logic_vector(23 downto 0) := (others => '0');
    signal Wanc, Wanc_d1 : vector_of_std_logic_vector24(0 to 11) := (others => (others => '0'));
    signal ANC_en : std_logic := '0';
    
    signal PRI_FilterIn, PRI_FilterOut : std_logic_vector(23 downto 0) := (others => '0');
    signal PRI_coeff : vector_of_std_logic_vector24(0 to 11) := (others => (others => '0'));
    signal PRI_en : std_logic := '0';
    
    signal tmp : vector_of_std_logic_vector24(0 to 15) := (others => (others => '0'));
    signal summation : std_logic_vector(23 downto 0) := (others => '0');
    signal ANC_FilterOut_inv : std_logic_vector(23 downto 0) := (others => '0');
begin

    reset <= '0'; clk_enable <= '1';
    
    CLOCK_ANC : process
    begin
        clk_anc <= '0';
        wait for t1/2;
        clk_anc <= '1';
        wait for t1/2;
    end process;
    
    CLOCK_SYS : process
    begin
        clk_dsp <= '0';
        wait for t2/2;
        clk_dsp <= '1';
        wait for t2/2;
    end process;
    
    SINE : entity work.sine_generator(amplitude_15)
    port map(
        clk => clk_anc,
        reset => reset,
        clk_enable => clk_enable,
        Out1 => sine_out
    );
    
    DELAY_REGISTER : process(clk_anc)
    begin
        if rising_edge(clk_anc) then
            Wanc_d1 <= Wanc;
        end if;
    end process;
    
    ESTIM_SEC_PATH : entity work.Discrete_FIR_Filter
    generic map(L => 12)
    port map(
        clk_anc => clk_anc,
        clk_dsp => clk_dsp,
        reset => reset,
        enb => ESP_en,
        input => ESP_FilterIn,
        coeff => ESP_Coeff,
        output => ESP_FilterOut
    );
        ESP_FilterIn <= sine_out;
        ESP_en <= '1';
        ESP_Coeff(0) <= "011101110100101111000110";-- 0.466
        ESP_Coeff(1) <= "100010000111001010110000";-- 0.533
            tmp(0) <= "010000011100101011000000";
        ESP_Coeff(2) <= std_logic_vector(-signed(tmp(0)));-- -0.257
            tmp(1) <= "010001100010010011011101";
        ESP_Coeff(3) <= std_logic_vector(-signed(tmp(1)));-- -0.274
            tmp(2) <= "001110110010001011010000";
        ESP_Coeff(4) <= std_logic_vector(-signed(tmp(2)));-- -0.231
            tmp(3) <= "001011001100110011001100";
        ESP_Coeff(5) <= std_logic_vector(-signed(tmp(3)));-- -0.175
    
--    LMS_Update_System : entity work.LMS_UPDATE --Unit Under Test
--    generic map(L => 12)
--    port map(
--        clk_anc => clk_anc,
--        clk_dsp => clk_dsp,
----        clk => clk_anc,
--        reset => reset,
--        enb => LMSU_en,
--        X => LMSU_input,
--        E => LMSU_error,
--        adapt => adapt,
--        W => Wanc
--    );
--        LMSU_input <= ESP_FilterOut;
--        LMSU_error <= summation;
--        LMSU_en <= '1';
--        adapt <= '1';
    
--    ANC_FILTER : entity work.Discrete_FIR_Filter_12
--    port map(
--        clk => clk_anc,
--        reset => reset,
--        enb => ANC_en,
--        Discrete_FIR_Filter_in => ANC_FilterIn,
--        Discrete_FIR_Filter_coeff => Wanc_d1,
--        Discrete_FIR_Filter_out => ANC_FilterOut
--    );
    ANC_FILTER : entity work.Discrete_FIR_Filter
    generic map(L => 12)
    port map(
        clk_anc => clk_anc,
        clk_dsp => clk_dsp,
        reset => reset,
        enb => ANC_en,
        input => ANC_FilterIn,
        coeff => Wanc_d1,
        output => ANC_FilterOut
    );
        ANC_FilterIn <= sine_out;
        ANC_FilterOut_inv <= std_logic_vector(-signed(ANC_FilterOut));
        ANC_en <= '1';
        
    SECONDARY_PATH : entity work.Discrete_FIR_Filter
    generic map(L => 12)
    port map(
        clk_anc => clk_anc,
        clk_dsp => clk_dsp,
        reset => reset,
        enb => SP_en,
        input => SP_FilterIn,
        coeff => SP_Coeff,
        output => SP_FilterOut
    );
        SP_FilterIn <= ANC_FilterOut_inv;
        SP_en <= '1';
        SP_Coeff(0) <= "011111010111000010100011"; -- 0.49
        SP_Coeff(1) <= "011111010111000010100011"; -- 0.49
            tmp(6) <= "010011001100110011001100";
        SP_Coeff(2) <= std_logic_vector(-signed(tmp(6))); -- -0.3
        SP_Coeff(3) <= std_logic_vector(-signed(tmp(6))); -- -0.3
            tmp(7) <= "001100110011001100110011";
        SP_Coeff(4) <= std_logic_vector(-signed(tmp(7))); -- -0.2
        SP_Coeff(5) <= std_logic_vector(-signed(tmp(7))); -- -0.2    
        --
    PRIMARY_PATH : entity work.Discrete_FIR_Filter --"lms filter copy in matlab"
    generic map(L => 12)
    port map(
        clk_anc => clk_anc,
        clk_dsp => clk_dsp,
        reset => reset,
        enb => PRI_en,
        input => PRI_FilterIn,
        coeff => PRI_Coeff,
        output => PRI_FilterOut
    );
        PRI_FilterIn <= sine_out;
        PRI_en <= '1';
        PRI_Coeff(0) <= "000011001100110011001100"; -- 0.05
        PRI_Coeff(1) <= (others => '0');
        PRI_Coeff(2) <= "000001010001111010111000"; -- 0.02
        PRI_Coeff(3) <= (others => '0');
        PRI_Coeff(4) <= (others => '0');
        PRI_Coeff(5) <= (others => '0');
            tmp(4) <= "001000000000000000000000"; 
        PRI_Coeff(6) <= std_logic_vector(-signed(tmp(4))); -- -0.125
        PRI_Coeff(7) <= (others => '0');
            tmp(5) <= "000011001100110011001100";
        PRI_Coeff(8) <= std_logic_vector(-signed(tmp(5))); -- -0.05 
        PRI_Coeff(9) <= (others => '0');
        PRI_Coeff(10) <= "000100110011001100110011"; -- 0.075
        PRI_Coeff(11) <= (others => '0');
        
    summation <= std_logic_vector( signed(PRI_FilterOut) + signed(SP_FilterOut));
    
end Behavioral;