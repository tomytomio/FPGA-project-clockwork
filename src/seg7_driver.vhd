-- seg7_driver.vhd
-- Multiplexed 4-digit 7-seg driver for common-anode displays on Basys3
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity seg7_driver is
    port (
        clk    : in std_logic; -- fast clock (we'll use 100 MHz divided externally or use 10kHz)
        rst_n  : in std_logic;
        digits : in unsigned(3 downto 0) vector(3 downto 0); -- 4 digits [3]=leftmost
        dp     : in std_logic_vector(3 downto 0); -- decimal points per digit
        blink_mask : in std_logic_vector(3 downto 0); -- '1' = visible, '0' = hidden when blinking off
        seg    : out std_logic_vector(6 downto 0); -- segments a..g
        an     : out std_logic_vector(3 downto 0)  -- anodes (active low on Basys3)
    );
end entity;

architecture rtl of seg7_driver is
    -- We'll build a small refresh counter to scan digits at ~1kHz per digit (4kHz total)
    constant REF_WIDTH : natural := 12; -- adjust for refresh rate
    signal ref_cnt : unsigned(REF_WIDTH-1 downto 0) := (others => '0');
    signal sel : unsigned(1 downto 0) := (others => '0');
    signal seg_r : std_logic_vector(6 downto 0);
    signal an_r  : std_logic_vector(3 downto 0) := (others => '1');

    function to_segments(d : unsigned(3 downto 0)) return std_logic_vector is
        variable s : std_logic_vector(6 downto 0);
    begin
        case to_integer(d) is
            when 0 => s := "0000001"; -- 0
            when 1 => s := "1001111"; -- 1
            when 2 => s := "0010010"; -- 2
            when 3 => s := "0000110"; -- 3
            when 4 => s := "1001100"; -- 4
            when 5 => s := "0100100"; -- 5
            when 6 => s := "0100000"; -- 6
            when 7 => s := "0001111"; -- 7
            when 8 => s := "0000000"; -- 8
            when 9 => s := "0000100"; -- 9
            when others => s := "1111111"; -- blank
        end case;
        return s;
    end function;

begin
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            ref_cnt <= (others => '0');
            sel <= (others => '0');
        elsif rising_edge(clk) then
            ref_cnt <= ref_cnt + 1;
            sel <= ref_cnt(ref_cnt'high downto ref_cnt'high-1);
        end if;
    end process;

    -- drive selected digit
    process(sel, digits, dp, blink_mask)
    begin
        case to_integer(sel) is
            when 0 =>
                seg_r <= to_segments(digits(0));
                an_r  <= "1110"; -- active low -> digit 0 active
                if dp(0) = '1' then seg_r(6) <= '1'; end if; -- dp mapped to g bit placeholder
                if blink_mask(0) = '0' then seg_r <= (others => '1'); end if;
            when 1 =>
                seg_r <= to_segments(digits(1));
                an_r  <= "1101";
                if dp(1) = '1' then seg_r(6) <= '1'; end if;
                if blink_mask(1) = '0' then seg_r <= (others => '1'); end if;
            when 2 =>
                seg_r <= to_segments(digits(2));
                an_r  <= "1011";
                if dp(2) = '1' then seg_r(6) <= '1'; end if;
                if blink_mask(2) = '0' then seg_r <= (others => '1'); end if;
            when others =>
                seg_r <= to_segments(digits(3));
                an_r  <= "0111";
                if dp(3) = '1' then seg_r(6) <= '1'; end if;
                if blink_mask(3) = '0' then seg_r <= (others => '1'); end if;
        end case;
    end process;

    seg <= seg_r;
    an  <= an_r;
end architecture;