-- clock_divider.vhd
-- Generates 10 Hz tick (0.1 s) from input clock (assumed 100 MHz on Basys3)
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clock_divider is
    port (
        clk_in  : in  std_logic; -- 100 MHz
        rst_n   : in  std_logic;
        tick_10hz : out std_logic; -- 10 Hz tick
        en_1hz    : out std_logic  -- 1 Hz enable (for seconds if needed)
    );
end entity;

architecture rtl of clock_divider is
    constant CLK_FREQ : natural := 100_000_000; -- 100 MHz
    constant TICK_FREQ : natural := 10; -- 10 Hz
    -- We toggle the output to create a square wave. For a square wave at TICK_FREQ,
    -- the half-period count must be CLK_FREQ / (2*TICK_FREQ) - 1
    -- keep COUNTER_MAX as half-period count used by previous implementation
    constant COUNTER_MAX : natural := CLK_FREQ / (2 * TICK_FREQ) - 1;

    signal cnt : unsigned(31 downto 0) := (others => '0');
    signal tick_r : std_logic := '0';
    -- only need small counter for 0..9 pulses
    signal sec_cnt : unsigned(3 downto 0) := (others => '0');
    signal one_hz : std_logic := '0';
begin
    process(clk_in, rst_n)
    begin
        if rst_n = '0' then
            cnt <= (others => '0');
            tick_r <= '0';
            sec_cnt <= (others => '0');
            one_hz <= '0';
        elsif rising_edge(clk_in) then
            if cnt = to_unsigned(COUNTER_MAX, cnt'length) then
                cnt <= (others => '0');
                -- generate a single-cycle 10Hz pulse
                tick_r <= '1';
                -- manage 1 Hz by counting 10 pulses of tick_r
                if sec_cnt = to_unsigned(9, sec_cnt'length) then
                    sec_cnt <= (others => '0');
                    one_hz <= '1';
                else
                    sec_cnt <= sec_cnt + 1;
                    one_hz <= '0';
                end if;
            else
                cnt <= cnt + 1;
                tick_r <= '0';
                one_hz <= '0';
            end if;
        end if;
    end process;

    tick_10hz <= tick_r;
    en_1hz <= one_hz;
end architecture;
