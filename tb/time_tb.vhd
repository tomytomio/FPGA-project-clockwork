-- time_tb.vhd
-- Behavioral testbench to exercise time counting and adjustment FSM
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity time_tb is
end entity;

architecture sim of time_tb is
    signal clk100 : std_logic := '0';
    signal btn0 : std_logic := '0';
    signal btn1 : std_logic := '0';
    signal btn2 : std_logic := '0';
    signal seg : std_logic_vector(7 downto 0);
    signal an  : std_logic_vector(3 downto 0);
    signal led : std_logic_vector(15 downto 0);

    component top
        port(clk100: in std_logic; btn0: in std_logic; btn1: in std_logic; btn2: in std_logic; seg: out std_logic_vector(7 downto 0); an: out std_logic_vector(3 downto 0); led: out std_logic_vector(15 downto 0));
    end component;

begin
    uut: top port map(clk100 => clk100, btn0 => btn0, btn1 => btn1, btn2 => btn2, seg => seg, an => an, led => led);

    -- CLK 100 MHz (run for entire simulation)
    clk_proc: process
    begin
        loop
            clk100 <= '0';
            wait for 5 ns;
            clk100 <= '1';
            wait for 5 ns;
        end loop;
    end process;

    stim_proc: process
    begin
        -- reset
        btn0 <= '1';
        wait for 20 ns;
        btn0 <= '0';

        -- wait some time to let clock count
        wait for 1 sec; -- let it count 1 second

        -- enter set hour mode (b1 pulse)
        btn1 <= '1';
        wait for 100 ms;
        btn1 <= '0';
        wait for 200 ms;

        -- press b2 to increment hour 2 times
        btn2 <= '1'; wait for 100 ms; btn2 <= '0'; wait for 200 ms;
        btn2 <= '1'; wait for 100 ms; btn2 <= '0'; wait for 200 ms;

        -- leave mode
        btn1 <= '1'; wait for 100 ms; btn1 <= '0'; wait for 200 ms;

        -- enter set minute mode
        btn1 <= '1'; wait for 100 ms; btn1 <= '0'; wait for 200 ms;

        -- increment minute
        btn2 <= '1'; wait for 100 ms; btn2 <= '0'; wait for 200 ms;

        -- reset seconds
        btn1 <= '1'; wait for 100 ms; btn1 <= '0'; wait for 200 ms;
        btn2 <= '1'; wait for 100 ms; btn2 <= '0'; wait for 200 ms;

        wait for 2 sec;
        wait;
    end process;
end architecture;