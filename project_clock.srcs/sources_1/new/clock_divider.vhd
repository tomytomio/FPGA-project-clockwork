-- clock_divider.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clock_divider is
    Port (
        clk      : in  std_logic;  -- 100 MHz input clock
        rst      : in  std_logic;  -- active-high reset
        clk10hz  : out std_logic;   -- output clock at 10 Hz (0.1 sec period)
        clk1khz  : out std_logic   -- output clock at 10 Hz (0.1 sec period)

    );
end clock_divider;

architecture Behavioral of clock_divider is
    constant MAX_10hz : integer := 50; -- to change for accurate reading
    constant MAX_1khz : integer := 5000; -- to change for accurate reading
    signal counter10hz     : integer range 0 to MAX_10hz := 0;
    signal counter1khz     : integer range 0 to MAX_1khz := 0;

    signal clk_reg10hz     : std_logic := '0';
    signal clk_reg1khz     : std_logic := '0';
    
begin
    process(clk, rst)
    begin
        if rst = '1' then
            counter10hz  <= 0;
            counter1khz <= 0;
            clk_reg10hz <= '0';
            clk_reg1khz <= '0';
            
        elsif rising_edge(clk) then
            if counter10hz = MAX_10hz then
                counter10hz <= 0;
                clk_reg10hz <= not clk_reg10hz;
            else
                counter10hz <= counter10hz + 1;
            end if;
            
            if counter1khz = MAX_1khz then
                counter1khz <= 0;
                clk_reg1khz <= not clk_reg1khz;
            else
                counter1khz <= counter1khz + 1;
            end if;
            
        end if;
    end process;

    clk10hz <= clk_reg10hz;
    clk1khz <= clk_reg1khz;

end Behavioral;