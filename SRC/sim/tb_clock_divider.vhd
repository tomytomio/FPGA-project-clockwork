-- tb_clock_divider.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_clock_divider is
end tb_clock_divider;

architecture behavior of tb_clock_divider is

    -- Component Declaration
    component clock_divider
        Port (
            clk      : in  std_logic;
            rst      : in  std_logic;
            clk10hz  : out std_logic;
            clk1khz  : out std_logic
        );
    end component;

    -- Signals for simulation
    signal clk_tb      : std_logic := '0';
    signal rst_tb      : std_logic := '1';
    signal clk10hz_tb  : std_logic := '0';
    signal clk1khz_tb  : std_logic := '0';

    constant CLK_PERIOD : time := 10 ns;  -- 100 MHz clock

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: clock_divider
        port map (
            clk     => clk_tb,
            rst     => rst_tb,
            clk10hz => clk10hz_tb,
            clk1khz => clk1khz_tb
        );

    -- Clock generation process
    clk_process : process
    begin
        while true loop
            clk_tb <= '0';
            wait for CLK_PERIOD / 2;
            clk_tb <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Initial reset
        wait for 100 ns;
        rst_tb <= '0';

        -- Run simulation for a while to observe clk10hz toggling
        wait for 15 sec;  -- simulate for 1 second (should see ~10 toggles)

        -- End simulation
        wait;
    end process;

end behavior;