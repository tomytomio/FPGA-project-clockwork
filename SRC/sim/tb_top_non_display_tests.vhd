library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_top is
end tb_top;

architecture Behavioral of tb_top is

    -- Signals matching top entity
    signal clk       : std_logic := '0';
    signal rst       : std_logic := '0';
    signal clk10hz   : std_logic;
    signal clk1khz   : std_logic;
    signal b1        : std_logic := '0';  -- button0 (mode switch)
    signal b2        : std_logic := '0';  -- button1 (set/increment)
    signal seg       : std_logic_vector(6 downto 0);
    signal an        : std_logic_vector(3 downto 0);

    constant clk_period : time := 10 ns;

begin

    ----------------------------------------------------------------------
    -- Instantiate DUT
    ----------------------------------------------------------------------
    uut: entity work.top
        port map (
            clk      => clk,
            rst      => rst,
            clk10hz  => clk10hz,
            clk1khz  => clk1khz,
            b1       => b1,
            b2       => b2,
            seg      => seg,
            an       => an
        );

    ----------------------------------------------------------------------
    -- Generate master 100 MHz clock
    ----------------------------------------------------------------------
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;


    ----------------------------------------------------------------------
    -- Testbench control: manually toggle clk10hz_sig inside UUT
    -- WARNING: This ONLY works because top exposes clk10hz as an OUT.
    --          This makes simulation fast. In hardware, divider controls it.
    ----------------------------------------------------------------------
    drive_clk10hz : process
    begin
        -- Give system time to initialize
        wait for 200 ns;

        while true loop
            uut.clk10hz_sig <= '1';
            wait for clk_period;
            uut.clk10hz_sig <= '0';
            wait for 9*clk_period;
        end loop;
    end process;


    ----------------------------------------------------------------------
    -- MAIN SIMULATION SEQUENCE
    ----------------------------------------------------------------------
    stimulus: process
    begin
        ------------------------------------------------------------------
        -- 1. Reset system
        ------------------------------------------------------------------
        rst <= '1';
        wait for 200 ns;
        rst <= '0';

        ------------------------------------------------------------------
        -- 2. Let time run for a few simulated ticks
        --    Watch ST, SU, SD increment
        ------------------------------------------------------------------
        wait for 20 * clk_period;

        ------------------------------------------------------------------
        -- 3. Press button0 (b1) to advance mode
        ------------------------------------------------------------------
        b1 <= '1'; wait for 30 ns; b1 <= '0';
        -- mode should go: 0000 -> 0001 ("set hour")

        wait for 50 ns;

        ------------------------------------------------------------------
        -- 4. Mode 1: set hour, press button1 to increment hours
        ------------------------------------------------------------------
        b2 <= '1'; wait for 30 ns; b2 <= '0';   -- hour++
        wait for 100 ns;

        b2 <= '1'; wait for 30 ns; b2 <= '0';   -- hour++
        wait for 100 ns;

        ------------------------------------------------------------------
        -- 5. Advance to next mode (Mode 2: set minute)
        ------------------------------------------------------------------
        b1 <= '1'; wait for 30 ns; b1 <= '0';
        wait for 50 ns;

        ------------------------------------------------------------------
        -- 6. Mode 2: increment minutes
        ------------------------------------------------------------------
        b2 <= '1'; wait for 30 ns; b2 <= '0';
        wait for 100 ns;

        b2 <= '1'; wait for 30 ns; b2 <= '0';
        wait for 100 ns;

        ------------------------------------------------------------------
        -- 7. Advance to Mode 3: reset seconds
        ------------------------------------------------------------------
        b1 <= '1'; wait for 30 ns; b1 <= '0';
        wait for 100 ns;

        ------------------------------------------------------------------
        -- 8. Mode 3: reset seconds+tenth
        ------------------------------------------------------------------
        b2 <= '1'; wait for 30 ns; b2 <= '0';
        wait for 200 ns;

        ------------------------------------------------------------------
        -- 9. Let the clock run again for several ticks
        ------------------------------------------------------------------
        wait for 20 * clk_period;

        ------------------------------------------------------------------
        -- End simulation
        ------------------------------------------------------------------
        wait;
    end process;

end Behavioral;
