-- top.vhd
-- Top-level for Basys3 mapping. Instantiates clock divider, time manager, FSM, blinker and seg driver
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types_pkg.all;

entity top is
    port (
        clk100 : in std_logic; -- 100 MHz
        btn0 : in std_logic; -- reset (active high on Basys3) but we'll use rst_n active low
        btn1 : in std_logic; -- b1 mode
        btn2 : in std_logic; -- b2 action
        -- leds and seven seg pins
        seg : out std_logic_vector(7 downto 0); -- include dp at bit 7
        an  : out std_logic_vector(3 downto 0);
        led : out std_logic_vector(15 downto 0)
    );
end entity;

architecture rtl of top is
    component clock_divider
        port(clk_in: in std_logic; rst_n: in std_logic; tick_10hz: out std_logic; en_1hz: out std_logic);
    end component;

    component time_manager
        port(clk_10hz: in std_logic; rst_n: in std_logic; inc_tenth: in std_logic; adj_hour: in std_logic; adj_min: in std_logic; rst_sec: in std_logic; digit_h10: out unsigned(3 downto 0); digit_h1: out unsigned(3 downto 0); digit_m10: out unsigned(3 downto 0); digit_m1: out unsigned(3 downto 0); digit_s10: out unsigned(3 downto 0); digit_s1: out unsigned(3 downto 0); digit_tenth: out unsigned(3 downto 0));
    end component;

    component adjust_fsm
        port(clk_10hz: in std_logic; rst_n: in std_logic; b1: in std_logic; b2: in std_logic; mode: out unsigned(2 downto 0); pulse_inc_hour: out std_logic; pulse_inc_min: out std_logic; pulse_reset_sec: out std_logic; blink_enable_mask: out std_logic_vector(3 downto 0));
    end component;

    component blinker
        port(tick_10hz: in std_logic; rst_n: in std_logic; enable: in std_logic; blink_out: out std_logic);
    end component;

    component seg7_driver
        port(clk: in std_logic; rst_n: in std_logic; digits: in digit_array; dp: in std_logic_vector(3 downto 0); blink_mask: in std_logic_vector(3 downto 0); seg: out std_logic_vector(7 downto 0); an: out std_logic_vector(3 downto 0));
    end component;

    signal rst_n : std_logic;
    signal tick_10hz : std_logic;
    signal en_1hz : std_logic;
    signal d_h10, d_h1, d_m10, d_m1, d_s10, d_s1, d_tenth : unsigned(3 downto 0);
    signal mode : unsigned(2 downto 0);
    signal pulse_inc_hour, pulse_inc_min, pulse_reset_sec : std_logic;
    signal blink_mask_raw : std_logic_vector(3 downto 0);
    signal blink_on : std_logic;
    signal digits_bus : digit_array;
    signal dp : std_logic_vector(3 downto 0) := (others => '0');
    signal blink_mask_final : std_logic_vector(3 downto 0);
    signal blink_enable_any : std_logic := '0';
    signal show_seconds : std_logic := '0';
    signal b2_d_top : std_logic := '0';
    signal blank_digit : digit_t := (others => '1');

begin
    rst_n <= not btn0; -- btn0 active high reset

    clkdiv : clock_divider port map(clk_in => clk100, rst_n => rst_n, tick_10hz => tick_10hz, en_1hz => en_1hz);

    fsm : adjust_fsm port map(clk_10hz => tick_10hz, rst_n => rst_n, b1 => btn1, b2 => btn2, mode => mode, pulse_inc_hour => pulse_inc_hour, pulse_inc_min => pulse_inc_min, pulse_reset_sec => pulse_reset_sec, blink_enable_mask => blink_mask_raw);

    tm : time_manager port map(clk_10hz => tick_10hz, rst_n => rst_n, inc_tenth => tick_10hz, adj_hour => pulse_inc_hour, adj_min => pulse_inc_min, rst_sec => pulse_reset_sec, digit_h10 => d_h10, digit_h1 => d_h1, digit_m10 => d_m10, digit_m1 => d_m1, digit_s10 => d_s10, digit_s1 => d_s1, digit_tenth => d_tenth);

    bl : blinker port map(tick_10hz => tick_10hz, rst_n => rst_n, enable => blink_enable_any, blink_out => blink_on);

    -- handle show-seconds toggle (b2 rising edge in normal mode toggles seconds display)
    process(tick_10hz, rst_n)
    begin
        if rst_n = '0' then
            b2_d_top <= '0';
            show_seconds <= '0';
        elsif rising_edge(tick_10hz) then
            b2_d_top <= btn2;
            if btn2 = '1' and b2_d_top = '0' and mode = "000" then
                show_seconds <= not show_seconds;
            end if;
        end if;
    end process;

    -- build display digits: show HH:MM by default; if show_seconds then show --SS on right two digits
    process(d_h10, d_h1, d_m10, d_m1, d_s10, d_s1, show_seconds, blank_digit)
    begin
        if show_seconds = '1' then
            digits_bus(3) <= blank_digit;
            digits_bus(2) <= blank_digit;
            digits_bus(1) <= d_s10;
            digits_bus(0) <= d_s1;
        else
            digits_bus(3) <= d_h10;
            digits_bus(2) <= d_h1;
            digits_bus(1) <= d_m10;
            digits_bus(0) <= d_m1;
        end if;
    end process;

    -- final blink mask: when a digit is marked to blink (blink_mask_raw bit = '1') its visibility follows blink_on;
    -- otherwise it is always visible ('1')
    process(blink_on, blink_mask_raw)
    begin
        for i in 0 to 3 loop
            if blink_mask_raw(i) = '1' then
                if blink_on = '1' then
                    blink_mask_final(i) <= '1';
                else
                    blink_mask_final(i) <= '0';
                end if;
            else
                blink_mask_final(i) <= '1';
            end if;
        end loop;
    end process;

    -- enable the blinker only when any digit is set to blink in the FSM
    process(blink_mask_raw)
    begin
        if blink_mask_raw = "0000" then
            blink_enable_any <= '0';
        else
            blink_enable_any <= '1';
        end if;
    end process;

    segdrv : seg7_driver port map(clk => clk100, rst_n => rst_n, digits => digits_bus, dp => dp, blink_mask => blink_mask_final, seg => seg, an => an);

    -- simple LED display of mode and seconds
    led(0) <= mode(0);
    led(1) <= mode(1);
    led(2) <= mode(2);
    led(15 downto 3) <= (others => '0');
end architecture;