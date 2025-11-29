library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity button_sync is
    Port (
        clk10hz   : in  std_logic;   -- 0.1 sec tick
        rst       : in  std_logic;
        button0_in     : in  std_logic;
        button1_in     : in  std_logic;
        button2_in     : in  std_logic;
        button3_in     : in  std_logic;
        button0_pulse  : out std_logic;
        button0_raw    : out std_logic;
        button1_pulse  : out std_logic;
        button1_raw    : out std_logic;
        button2_pulse  : out std_logic;
        button2_raw    : out std_logic;
        button3_pulse  : out std_logic;
        button3_raw    : out std_logic;
    );
end button_sync;

architecture Behavioral of button_sync is

    signal button0_prev, button1_prev, button2_prev, button3_prev : std_logic := '0';
    signal button0_curr, button1_curr, button2_curr, button3_curr : std_logic := '0';

begin

process(clk10hz, rst)
begin
    if rst = '1' then
        button0_prev <= '0';
        button1_prev <= '0';
        button2_prev <= '0';
        button3_prev <= '0';

        button0_curr <= '0';
        button1_curr <= '0';
        button2_curr <= '0';
        button3_curr <= '0';
    elsif rising_edge(clk10hz) then
        button0_prev <= button0_curr;
        button1_prev <= button1_curr;
        button2_prev <= button2_curr;
        button3_prev <= button3_curr;

        button0_curr <= button0_in;
        button1_curr <= button1_in;
        button2_curr <= button2_in;
        button3_curr <= button3_in;
    end if;
end process;

-- One-pulse-per-press generation
button0_pulse <= '1' when (button0_prev = '0' and button0_curr = '1') else '0';
button1_pulse <= '1' when (button1_prev = '0' and button1_curr = '1') else '0';
button2_pulse <= '1' when (button2_prev = '0' and button2_curr = '1') else '0';
button3_pulse <= '1' when (button3_prev = '0' and button3_curr = '1') else '0';
button0_raw   <= button0_curr;
button1_raw   <= button1_curr;
button2_raw   <= button2_curr;
button3_raw   <= button3_curr;

end Behavioral;
