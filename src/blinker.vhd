-- blinker.vhd
-- Produces blink signal: 0.7s on, 0.3s off when enabled. Uses 10Hz tick as base.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity blinker is
    port (
        tick_10hz : in std_logic; -- rising edge each 0.1s
        rst_n : in std_logic;
        enable : in std_logic;
        blink_out : out std_logic
    );
end entity;

architecture rtl of blinker is
    signal cnt : unsigned(3 downto 0) := (others => '0'); -- counts 0..9 (1s)
    signal on_period : unsigned(3 downto 0) := to_unsigned(7,4); -- 0.7s => 7 ticks
    signal state : std_logic := '0';
begin
    process(tick_10hz, rst_n)
    begin
        if rst_n = '0' then
            cnt <= (others => '0');
            state <= '1';
        elsif rising_edge(tick_10hz) then
            if enable = '1' then
                if cnt = to_unsigned(9, cnt'length) then
                    cnt <= (others => '0');
                else
                    cnt <= cnt + 1;
                end if;
                if cnt < on_period then
                    state <= '1';
                else
                    state <= '0';
                end if;
            else
                cnt <= (others => '0');
                state <= '1';
            end if;
        end if;
    end process;

    blink_out <= state;
end architecture;