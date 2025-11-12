-- top.vhd
-- Top-level for Basys3 mapping. Instantiates clock divider, time manager, FSM, blinker and seg driver
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
    port (
        clk100 : in std_logic; -- 100 MHz
        btn0 : in std_logic; -- reset (active high on Basys3) but we'll use rst_n active low
        btn1 : in std_logic; -- b1 mode
        btn2 : in std_logic; -- b2 action
        -- leds and seven seg pins
        seg : out std_logic_vector(6 downto 0);
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
        port(clk: in std_logic; rst_n: in std_logic; digits: in unsigned(3 downto 0) vector(3 downto 0); dp: in std_logic_vector(3 downto 0); blink_mask: in std_logic_vector(3 downto 0); seg: out std_logic_vector(6 downto 0); an: out std_logic_vector(3 downto 0));
    end component;

    signal rst_n : std_logic;
    signal tick_10hz : std_logic;
    signal en_1hz : std_logic;
    signal d_h10, d_h1, d_m10, d_m1, d_s10, d_s1, d_tenth : unsigned(3 downto 0);
    signal mode : unsigned(2 downto 0);
    signal pulse_inc_hour, pulse_inc_min, pulse_reset_sec : std_logic;
    signal blink_mask_raw : std_logic_vector(3 downto 0);
    signal blink_on : std_logic;
    signal digits_bus : unsigned(3 downto 0) vector(3 downto 0);
    signal dp : std_logic_vector(3 downto 0) := (others => '0');
    signal blink_mask_final : std_logic_vector(3 downto 0);

begin
    rst_n <= not btn0; -- btn0 active high reset

    clkdiv : clock_divider port map(clk_in => clk100, rst_n => rst_n, tick_10hz => tick_10hz, en_1hz => en_1hz);

    fsm : adjust_fsm port map(clk_10hz => tick_10hz, rst_n => rst_n, b1 => btn1, b2 => btn2, mode => mode, pulse_inc_hour => pulse_inc_hour, pulse_inc_min => pulse_inc_min, pulse_reset_sec => pulse_reset_sec, blink_enable_mask => blink_mask_raw);

    tm : time_manager port map(clk_10hz => tick_10hz, rst_n => rst_n, inc_tenth => tick_10hz, adj_hour => pulse_inc_hour, adj_min => pulse_inc_min, rst_sec => pulse_reset_sec, digit_h10 => d_h10, digit_h1 => d_h1, digit_m10 => d_m10, digit_m1 => d_m1, digit_s10 => d_s10, digit_s1 => d_s1, digit_tenth => d_tenth);

    bl : blinker port map(tick_10hz => tick_10hz, rst_n => rst_n, enable => '1', blink_out => blink_on);

    -- build display digits: by default show HH:MM on digits 3..0 (H tens, H ones, M tens, M ones)
    digits_bus(3) <= d_h10;
    digits_bus(2) <= d_h1;
    digits_bus(1) <= d_m10;
    digits_bus(0) <= d_m1;

    -- final blink mask: when blink_on = '0', hide digits with zero in mask
    process(blink_on, blink_mask_raw)
    begin
        for i in 0 to 3 loop
            if blink_on = '1' then
                blink_mask_final(i) <= '1';
            else
                blink_mask_final(i) <= blink_mask_raw(i);
            end if;
        end loop;
    end process;

    segdrv : seg7_driver port map(clk => clk100, rst_n => rst_n, digits => digits_bus, dp => dp, blink_mask => blink_mask_final, seg => seg, an => an);

    -- simple LED display of mode and seconds
    led(0) <= mode(0);
    led(1) <= mode(1);
    led(2) <= mode(2);
    led(15 downto 3) <= (others => '0');
end architecture;