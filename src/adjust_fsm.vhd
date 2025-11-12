-- adjust_fsm.vhd
-- Mode FSM controlled by push buttons b1 (mode) and b2 (action).
-- b1: advance mode; b2: action in mode (increment/toggle/reset)
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adjust_fsm is
    port (
        clk_10hz : in std_logic; -- tick used for debouncing and blink timing domain
        rst_n    : in std_logic;
        b1       : in std_logic; -- mode switch (active high pulse)
        b2       : in std_logic; -- action (active high pulse)
        -- outputs
        mode     : out unsigned(2 downto 0); -- supports modes 0..6 (we use 3 bits)
        pulse_inc_hour : out std_logic;
        pulse_inc_min  : out std_logic;
        pulse_reset_sec : out std_logic;
        blink_enable_mask : out std_logic_vector(3 downto 0) -- which digits blink when blink signal low
    );
end entity;

architecture rtl of adjust_fsm is
    signal cur_mode : unsigned(2 downto 0) := (others => '0');
    -- simple edge detectors for buttons (assume buttons produce single-cycle pulses from top)
    signal b1_d, b2_d : std_logic := '0';

begin
    process(clk_10hz, rst_n)
    begin
        if rst_n = '0' then
            cur_mode <= (others => '0');
            b1_d <= '0';
            b2_d <= '0';
            pulse_inc_hour <= '0';
            pulse_inc_min <= '0';
            pulse_reset_sec <= '0';
            blink_enable_mask <= (others => '1');
        elsif rising_edge(clk_10hz) then
            -- sample
            b1_d <= b1;
            b2_d <= b2;
            -- advance mode on rising edge of b1
            if b1 = '1' and b1_d = '0' then
                if cur_mode = "110" then -- 6
                    cur_mode <= (others => '0');
                else
                    cur_mode <= cur_mode + 1;
                end if;
            end if;

            -- action on rising edge of b2
            pulse_inc_hour <= '0';
            pulse_inc_min <= '0';
            pulse_reset_sec <= '0';
            if b2 = '1' and b2_d = '0' then
                case cur_mode is
                    when "000" => -- normal: toggle display or stop alarm
                        null;
                    when "001" => -- set hour
                        pulse_inc_hour <= '1';
                    when "010" => -- set minute
                        pulse_inc_min <= '1';
                    when "011" => -- reset seconds/tenths
                        pulse_reset_sec <= '1';
                    when others => null; -- alarm modes optional
                end case;
            end if;

            -- blink mask: when in adjust modes (1 hour, 2 minute, 3 reset) make affected digits blink
            case cur_mode is
                when "001" => -- set hour -> blink hour digits
                    blink_enable_mask <= "1100"; -- left two digits visible
                when "010" => -- set minute -> blink minute digits
                    blink_enable_mask <= "0011";
                when "011" => -- reset seconds/tenths -> blink seconds digits
                    blink_enable_mask <= "0000"; -- blink seconds (we won't display seconds in default)
                when others =>
                    blink_enable_mask <= (others => '1');
            end case;
        end if;
    end process;

    mode <= cur_mode;
end architecture;