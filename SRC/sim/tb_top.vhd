library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_top is
end tb_top;

architecture behavior of tb_top is

    -- Component Declaration (top entity)
    component top
        Port (
            clk    : in  std_logic;
            rst    : in  std_logic;
            clk10hz  : out std_logic;
            clk1khz  : out std_logic;
            b1     : in  std_logic;
            b2     : in  std_logic;
            seg    : out std_logic_vector(6 downto 0);
            an     : out std_logic_vector(3 downto 0)
        );
    end component;

    -- Signals to connect to top
    signal clk_tb    : std_logic := '0';
    signal rst_tb    : std_logic := '1';
    signal b1_tb     : std_logic := '0';
    signal b2_tb     : std_logic := '0';
    signal seg_tb    : std_logic_vector(6 downto 0);
    signal an_tb     : std_logic_vector(3 downto 0);
    
    --Signals for clock
    signal clk10hz_tb  : std_logic := '0';
    signal clk1khz_tb  : std_logic := '0';

    constant CLK_PERIOD   : time := 10   ns;  -- 1000 MHz main clock
    constant SIM_DURATION : time := 5 sec;

begin

    -- Instantiate top (which contains clock_divider and display controller)
    uut_top: top
        port map (
            clk => clk_tb,
            rst => rst_tb,
            clk10hz => clk10hz_tb,
            clk1khz => clk1khz_tb,
            b1  => b1_tb,
            b2  => b2_tb,
            seg => seg_tb,
            an  => an_tb
        );

    -- Generate main clock (100 MHz)
    clk_proc : process
    begin
        while now < SIM_DURATION loop
            clk_tb <= '0';
            wait for CLK_PERIOD/2;
            clk_tb <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process clk_proc;

    -- Stimulus: reset release and button presses to cycle display controller states
    stim_proc: process
    begin
        -- Hold reset for a short while
        rst_tb <= '1';
        wait for 100 ns;
        rst_tb <= '0';

        -- Give the design some time to settle
        wait for 10 ms;

        -- Cycle b1 to advance through ALL_ON -> ALL_OFF -> BLINK -> ALL_ON
        -- Each press is a short pulse; waits between presses let the divider and blink logic run
        for i in 0 to 2 loop
            wait for 200 ms;
            b1_tb <= '1';
            report "Pressing b1 at " & time'image(now);
            wait for 20 ms; -- short button press
            b1_tb <= '0';
        end loop;

        -- Wait to observe blink behavior
        wait for 500 ms;

        report "End of stimulus at " & time'image(now);

        wait;
    end process stim_proc;

end behavior;