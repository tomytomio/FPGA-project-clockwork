library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_display_driver is
end tb_display_driver;

architecture behavior of tb_display_driver is

    -- Component declaration
    component display_driver
        Port (
            HD        : in  std_logic_vector(3 downto 0);
            HU        : in  std_logic_vector(3 downto 0);
            MD        : in  std_logic_vector(3 downto 0);
            MU        : in  std_logic_vector(3 downto 0);
            SD        : in  std_logic_vector(3 downto 0);
            SU        : in  std_logic_vector(3 downto 0);
            ST        : in  std_logic_vector(3 downto 0);
            clk1khz   : in  std_logic;
            status    : in  std_logic_vector(3 downto 0);
            button1   : in  std_logic;
            alarm_on  : in  std_logic;

            an        : out std_logic_vector(3 downto 0);
            seg       : out std_logic_vector(6 downto 0)
        );
    end component;

    -- Signals to connect to DUT
    signal HD_s,HU_s, MD_s, MU_s, SD_s, SU_s, ST_s : std_logic_vector(3 downto 0) := (others => '0');
    signal clk1khz_s : std_logic := '0';
    signal status_s  : std_logic_vector(3 downto 0) := (others => '0');
    signal button1_s : std_logic := '0';

    signal an_s : std_logic_vector(3 downto 0);
    signal seg_s : std_logic_vector(6 downto 0);
    signal alarm_on_s : std_logic := '0';

    -- monitoring
    signal tick_count : integer := 0;

begin

    uut: display_driver
        port map (
            HD => HD_s,
            HU => HU_s,
            MD => MD_s,
            MU => MU_s,
            SD => SD_s,
            SU => SU_s,
            ST => ST_s,
            clk1khz => clk1khz_s,
            status => status_s,
            button1 => button1_s,
            an => an_s,
            seg => seg_s,
            alarm_on => alarm_on_s
        );

    -- Generate 1 kHz refresh clock (period = 1 ms)
    clk_gen: process
    begin
        while now < 10 sec loop
            clk1khz_s <= '0';
            wait for 500 us;
            clk1khz_s <= '1';
            wait for 500 us;
        end loop;
        wait;
    end process clk_gen;

    -- Stimulus: step through modes and toggle inputs to exercise behaviours
    stim_proc: process
    begin
        -- initial values: set a known time 12:34:56.7
        HD_s <= std_logic_vector(to_unsigned(1,4)); -- 1
        HU_s <= std_logic_vector(to_unsigned(2,4)); -- 2
        MD_s <= std_logic_vector(to_unsigned(3,4)); -- 3
        MU_s <= std_logic_vector(to_unsigned(4,4)); -- 4
        SD_s <= std_logic_vector(to_unsigned(5,4)); -- 5
        SU_s <= std_logic_vector(to_unsigned(6,4)); -- 6
        ST_s <= std_logic_vector(to_unsigned(7,4)); -- .7

        wait for 10 ms;

        -- Mode 0: normal display HH:MM
        status_s <= std_logic_vector(to_unsigned(0,4));
        report "Switch to mode 0 (normal)";
        wait for 200 ms;
        -- press button to show SS.T0
        button1_s <= '1';
        report "Button pressed to show SS.T0";
        wait for 60 ms;
        button1_s <= '0';
        wait for 200 ms;

        -- Mode 1: set hour (HH:St blinking)
        status_s <= std_logic_vector(to_unsigned(1,4));
        report "Switch to mode 1 (set hour)";
        -- change hour to 09
        HD_s <= "0000"; HU_s <= std_logic_vector(to_unsigned(9,4));
        wait for 600 ms;

        -- Mode 2: set minute (St:MM blinking)
        status_s <= std_logic_vector(to_unsigned(2,4));
        report "Switch to mode 2 (set minute)";
        MD_s <= std_logic_vector(to_unsigned(5,4)); MU_s <= std_logic_vector(to_unsigned(9,4));
        wait for 600 ms;

        -- Mode 3: reset (SS:St blinking)
        status_s <= std_logic_vector(to_unsigned(3,4));
        report "Switch to mode 3 (reset)";
        SD_s <= std_logic_vector(to_unsigned(0,4)); SU_s <= std_logic_vector(to_unsigned(0,4)); ST_s <= std_logic_vector(to_unsigned(0,4));
        wait for 600 ms;

        -- Mode 4: toggle ALOn/ALOf
        status_s <= std_logic_vector(to_unsigned(4,4));
        report "Switch to mode 4 (toggle). Press button to toggle alarm";
        wait for 100 ms;
        -- press to toggle alarm on (drive alarm_on directly for this TB)
        alarm_on_s <= '1';
        wait for 40 ms; alarm_on_s <= '1';
        wait for 200 ms;
        -- press to toggle alarm off
        alarm_on_s <= '0';
        wait for 40 ms; alarm_on_s <= '0';
        wait for 200 ms;

        -- Mode 5: set alarm HH:AL (AL blinking)
        status_s <= std_logic_vector(to_unsigned(5,4));
        report "Switch to mode 5 (set alarm HH:AL)";
        HD_s <= "0001"; HU_s <= std_logic_vector(to_unsigned(8,4));
        wait for 600 ms;

        -- Mode 6: set alarm AL:MM (AL blinking)
        status_s <= std_logic_vector(to_unsigned(6,4));
        report "Switch to mode 6 (set alarm AL:MM)";
        MD_s <= std_logic_vector(to_unsigned(0,4)); MU_s <= std_logic_vector(to_unsigned(7,4));
        wait for 600 ms;

        report "Testbench finished";
        wait;
    end process stim_proc;

end behavior;
