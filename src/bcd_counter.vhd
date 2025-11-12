-- bcd_counter.vhd
-- Generic 0-9 BCD counter with enable, increment, load, and reset
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bcd_counter is
    generic (
        DIGITS : natural := 1; -- not used but for compatibility
        MAX_VAL : natural := 9
    );
    port (
        clk   : in std_logic;
        rst_n : in std_logic;
        en    : in std_logic; -- increment when high on rising edge
        load  : in std_logic;
        load_val : in unsigned(3 downto 0);
        clr   : in std_logic; -- asynchronous clear to 0
        q     : out unsigned(3 downto 0)
    );
end entity;

architecture rtl of bcd_counter is
    signal val : unsigned(3 downto 0) := (others => '0');
begin
    process(clk, rst_n, clr)
    begin
        if rst_n = '0' then
            val <= (others => '0');
        elsif clr = '1' then
            val <= (others => '0');
        elsif rising_edge(clk) then
            if load = '1' then
                val <= load_val;
            elsif en = '1' then
                if to_integer(val) = MAX_VAL then
                    val <= (others => '0');
                else
                    val <= val + 1;
                end if;
            end if;
        end if;
    end process;

    q <= val;
end architecture;