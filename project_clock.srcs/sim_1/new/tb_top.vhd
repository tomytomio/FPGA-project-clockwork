library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_display_state_controller is
end tb_display_state_controller;

architecture behavior of tb_display_state_controller is

    -- Component Declaration
    component display_state_controller
        Port (
            clk       : in  std_logic;
            clk_blink : in  std_logic;
            rst       : in  std_logic;
            b1        : in  std_logic;
            b2        : in  std_logic;
            b3        : in  std_logic;
            b4        : in  std_logic;
            seg       : out std_logic_vector(6 downto 0);
            an        : out std_logic_vector(3 downto 0)
        );
    end component;

    -- Signals
    signal clk_tb       : std_logic := '0';
    signal clk_blink_tb : std_logic := '0';
    signal rst_tb       : std_logic := '1';
    signal b1_tb        : std_logic := '0';
    signal b2_tb        : std_logic := '0';
    signal b3_tb        : std_logic := '0';
    signal b4_tb        : std_logic := '0';
    signal seg_tb       : std_logic_vector(6 downto 0);
    signal an_tb        : std_logic_vector(3 downto 0);

    constant CLK_PERIOD       : time := 10 ns;     -- 100 MHz
    constant BLINK_PERIOD     : time := 500 ms;    -- 1 Hz blinking (toggle every 0.5s)
    constant SIM_DURATION     : time := 5 sec;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: display_state_controller
        port map (
            clk       => clk_tb,
            clk_blink => clk_blink_tb,
            rst       => rst_tb,
            b1        => b1_tb,
            b2        => b2_tb,
            b3        => b3_tb,
            b4        => b4_tb,
            seg       => seg_tb,
            an        => an_tb
        );

    -- Generate 100 MHz clock
    clk_process : process
    begin
        while now < SIM_DURATION loop
            clk_tb <= '0';
            wait for CLK_PERIOD / 2;
            clk_tb <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    -- Stimulus process: simulate reset and button presses
    stim_proc: process
    begin
        -- Initial reset
        wait for 100 ns;
        rst_tb <= '0';

        -- Press b1 every 1 second to switch state
        for i in 0 to 4 loop
            wait for 1 sec;
            b1_tb <= '1';
            wait for 50 ms;  -- simulate short button press
            b1_tb <= '0';
        end loop;

        wait;
    end process;

end behavior;