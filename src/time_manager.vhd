-- time_manager.vhd
-- Manages HH:MM:SS.T using BCD counters. Keeps counting during adjustments.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity time_manager is
    port (
        clk_10hz : in std_logic; -- base tick 0.1s
        rst_n    : in std_logic;
        inc_tenth : in std_logic; -- pulse at 10Hz to increment tenths
        adj_hour : in std_logic; -- pulse to increment hour (from FSM)
        adj_min  : in std_logic; -- pulse to increment minute (from FSM)
        rst_sec  : in std_logic; -- pulse to reset seconds and tenths
        -- BCD digit outputs: digits(3) = H tens, digits(2)=H units, digits(1)=M tens, digits(0)=M units, we will map for display
        digit_h10 : out unsigned(3 downto 0);
        digit_h1  : out unsigned(3 downto 0);
        digit_m10 : out unsigned(3 downto 0);
        digit_m1  : out unsigned(3 downto 0);
        digit_s10 : out unsigned(3 downto 0);
        digit_s1  : out unsigned(3 downto 0);
        digit_tenth : out unsigned(3 downto 0)
    );
end entity;

architecture rtl of time_manager is
    component bcd_counter
        generic (MAX_VAL : natural := 9);
        port(clk: in std_logic; rst_n: in std_logic; en: in std_logic; load: in std_logic; load_val: in unsigned(3 downto 0); clr: in std_logic; q: out unsigned(3 downto 0));
    end component;

    signal t_tenth : unsigned(3 downto 0);
    signal s_ones, s_tens : unsigned(3 downto 0);
    signal m_ones, m_tens : unsigned(3 downto 0);
    signal h_ones, h_tens : unsigned(3 downto 0);

    signal carry_tenth : std_logic;
    signal carry_s1 : std_logic;
    signal carry_s10 : std_logic;
    signal carry_m1 : std_logic;
    signal carry_m10 : std_logic;
    signal carry_h1 : std_logic;
    -- hour increment/load control to handle 00..23 wrapping
    signal h1_en_raw : std_logic;
    signal h1_en : std_logic;
    signal h1_load : std_logic := '0';
    signal h10_load : std_logic := '0';
    signal h1_load_val : unsigned(3 downto 0) := (others => '0');
    signal h10_load_val : unsigned(3 downto 0) := (others => '0');
begin
    -- tenths (0..9) increments every 0.1s
    tenths_inst : bcd_counter
        generic map (MAX_VAL => 9)
        port map(clk => clk_10hz, rst_n => rst_n, en => inc_tenth, load => '0', load_val => (others => '0'), clr => '0', q => t_tenth);

    -- seconds ones (0..9), increments when tenths rolls from 9->0. We'll detect by using inc_tenth and reading t_tenth
    s1_inst : bcd_counter
        generic map (MAX_VAL => 9)
        port map(clk => clk_10hz, rst_n => rst_n, en => carry_tenth, load => '0', load_val => (others => '0'), clr => rst_sec, q => s_ones);

    -- seconds tens (0..5)
    s10_inst : bcd_counter
        generic map (MAX_VAL => 5)
        port map(clk => clk_10hz, rst_n => rst_n, en => carry_s1, load => '0', load_val => (others => '0'), clr => rst_sec, q => s_tens);

    -- minutes ones (0..9)
    m1_inst : bcd_counter
        generic map (MAX_VAL => 9)
        port map(clk => clk_10hz, rst_n => rst_n, en => carry_s10, load => '0', load_val => (others => '0'), clr => '0', q => m_ones);

    -- minutes tens (0..5)
    m10_inst : bcd_counter
        generic map (MAX_VAL => 5)
        port map(clk => clk_10hz, rst_n => rst_n, en => carry_m1, load => '0', load_val => (others => '0'), clr => '0', q => m_tens);

    -- hours ones (0..9 by default, but we'll control wrapping to enforce 00..23)
    h1_inst : bcd_counter
        generic map (MAX_VAL => 9)
        port map(clk => clk_10hz, rst_n => rst_n, en => h1_en, load => h1_load, load_val => h1_load_val, clr => '0', q => h_ones);

    -- hours tens (0..2)
    h10_inst : bcd_counter
        generic map (MAX_VAL => 2)
        port map(clk => clk_10hz, rst_n => rst_n, en => carry_h1, load => h10_load, load_val => h10_load_val, clr => '0', q => h_tens);

    -- carry generation
    process(clk_10hz, rst_n)
    begin
        if rst_n = '0' then
            carry_tenth <= '0';
            carry_s1 <= '0';
            carry_s10 <= '0';
            carry_m1 <= '0';
            carry_m10 <= '0';
            carry_h1 <= '0';
        elsif rising_edge(clk_10hz) then
            -- detect tenths rollover: when inc_tenth is '1' and current tenths = 9
            if inc_tenth = '1' and t_tenth = "1001" then
                carry_tenth <= '1';
            else
                carry_tenth <= '0';
            end if;

            if carry_tenth = '1' and s_ones = "1001" then
                carry_s1 <= '1';
            else
                carry_s1 <= '0';
            end if;

            if carry_s1 = '1' and s_tens = "0101" then
                carry_s10 <= '1';
            else
                carry_s10 <= '0';
            end if;

            if carry_s10 = '1' and m_ones = "1001" then
                carry_m1 <= '1';
            else
                carry_m1 <= '0';
            end if;

            if carry_m1 = '1' and m_tens = "0101" then
                carry_m10 <= '1';
            else
                carry_m10 <= '0';
            end if;

            -- hour handling: support proper 00..23 wrapping on minute carry or manual hour increment
            -- determine if we are incrementing hours this cycle
            h1_en_raw <= carry_m10 or adj_hour;
            -- default: clear loads
            h1_load <= '0';
            h10_load <= '0';

            if h1_en_raw = '1' then
                -- if hours == 23 then wrap to 00
                if h_tens = "0010" and h_ones = "0011" then
                    h1_load <= '1';
                    h1_load_val <= (others => '0');
                    h10_load <= '1';
                    h10_load_val <= (others => '0');
                    carry_h1 <= '0';
                else
                    -- normal increment: if h_ones will roll from 9->0, request carry to h10
                    if h_ones = "1001" then
                        carry_h1 <= '1';
                    else
                        carry_h1 <= '0';
                    end if;
                end if;
            else
                carry_h1 <= '0';
            end if;

            -- finalize effective enables: if we are loading, inhibit the normal increment enable
            if h1_load = '1' then
                h1_en <= '0';
            else
                h1_en <= h1_en_raw;
            end if;
        end if;
    end process;

    -- connect outputs
    digit_tenth <= t_tenth;
    digit_s1 <= s_ones;
    digit_s10 <= s_tens;
    digit_m1 <= m_ones;
    digit_m10 <= m_tens;
    digit_h1 <= h_ones;
    digit_h10 <= h_tens;
end architecture;