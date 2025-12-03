library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_top_sim is
end tb_top_sim;

architecture Behavioral of tb_top_sim is

    -- Testbench-driven signals
    signal clk10hz_tb : std_logic := '0';
    signal rst        : std_logic := '0';
    signal b1         : std_logic := '0';
    signal b2         : std_logic := '0';

    -- Outputs from DUT
    signal status_o : std_logic_vector(3 downto 0);
    signal HD_o, HU_o : std_logic_vector(3 downto 0);
    signal MD_o, MU_o : std_logic_vector(3 downto 0);
    signal SD_o, SU_o : std_logic_vector(3 downto 0);
    signal ST_o       : std_logic_vector(3 downto 0);

    constant clk10hz_period : time := 100 ns;  -- simulation speed

begin

    ----------------------------------------------------------------------
    -- Instantiate the DUT (top_sim)
    ----------------------------------------------------------------------
    uut: entity work.top_sim
        port map (
            clk10hz  => clk10hz_tb,
            rst      => rst,
            b1       => b1,
            b2       => b2,

            status_o => status_o,
            HD_o     => HD_o,
            HU_o     => HU_o,
            MD_o     => MD_o,
            MU_o     => MU_o,
            SD_o     => SD_o,
            SU_o     => SU_o,
            ST_o     => ST_o
        );

    ----------------------------------------------------------------------
    -- Generate manual clk10hz
    ----------------------------------------------------------------------
    clkgen : process
    begin
        clk10hz_tb <= '1';
        wait for clk10hz_period/2;
        clk10hz_tb <= '0';
        wait for clk10hz_period/2;
    end process;

    ----------------------------------------------------------------------
    -- Stimulus process
    ----------------------------------------------------------------------
    stimulus : process
    begin
        ------------------------------------------------------------------
        -- Reset
        ------------------------------------------------------------------
        rst <= '1';
        wait for 200 ns;
        rst <= '0';

        ------------------------------------------------------------------
        -- Let time run for a few ticks
        ------------------------------------------------------------------
        wait for 10 * clk10hz_period;

        ------------------------------------------------------------------
        -- Step through modes: press b1 (button0)
        ------------------------------------------------------------------
        b1 <= '1'; wait for 200 ns; b1 <= '0';
        wait for 5 * clk10hz_period;

        ------------------------------------------------------------------
        -- Mode 1: set hour – press b2 (button1)
        ------------------------------------------------------------------
        b2 <= '1'; wait for 200 ns; b2 <= '0';
        wait for clk10hz_period;

        b2 <= '1'; wait for 200 ns; b2 <= '0';
        wait for clk10hz_period;

        ------------------------------------------------------------------
        -- Advance to Mode 2
        ------------------------------------------------------------------
        b1 <= '1'; wait for 200 ns; b1 <= '0';
        wait for clk10hz_period;

        ------------------------------------------------------------------
        -- Mode 2: minute increment
        ------------------------------------------------------------------
        b2 <= '1'; wait for 200 ns; b2 <= '0';
        wait for clk10hz_period;

        ------------------------------------------------------------------
        -- Advance to Mode 3
        ------------------------------------------------------------------
        b1 <= '1'; wait for 200 ns; b1 <= '0';
        wait for clk10hz_period;

        ------------------------------------------------------------------
        -- Mode 3: seconds reset
        ------------------------------------------------------------------
        b2 <= '1'; wait for 200 ns; b2 <= '0';
        wait for 5 * clk10hz_period;

        ------------------------------------------------------------------
        -- Let clock run
        ------------------------------------------------------------------
        wait for 20 * clk10hz_period;

        wait;
    end process;

end Behavioral;
