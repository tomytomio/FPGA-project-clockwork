library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top is
    Port (
        clk    : in  std_logic;  -- 100 MHz clock from Basys 3
        rst    : in  std_logic;
        b0     : in  std_logic;
        b1     : in  std_logic;
        seg    : out std_logic_vector(6 downto 0);
        an     : out std_logic_vector(3 downto 0)
    );
end top;

architecture Behavioral of top is

    -- Internal signals
    signal clk1khz_sig : std_logic;
    signal clk10hz_sig : std_logic;

    signal button0_pulse : std_logic;
    signal button1_pulse : std_logic;
    signal button2_pulse : std_logic;
    signal button3_pulse : std_logic;

    signal button0_raw   : std_logic;

    signal status : std_logic_vector(3 downto 0);

    signal HD, HU : std_logic_vector(3 downto 0);
    signal MD, MU : std_logic_vector(3 downto 0);
    signal SD, SU : std_logic_vector(3 downto 0);
    signal ST     : std_logic_vector(3 downto 0);


    -- Component declarations
    component clock_divider
        Port (
            clk      : in  std_logic;
            rst      : in  std_logic;
            clk10hz  : out std_logic;
            clk1khz  : out std_logic
        );
    end component;

    component button_sync is
        Port (
            clk10hz       : in  std_logic;
            rst           : in  std_logic;
            button0_in    : in  std_logic;
            button1_in    : in  std_logic;
            button2_in    : in  std_logic;
            button3_in    : in  std_logic;

            button0_pulse : out std_logic;
            button0_raw   : out std_logic;
            button1_pulse : out std_logic;
            button2_pulse : out std_logic;
            button3_pulse : out std_logic
        );
    end component;

    component mode_fsm is
        Port (
            clk10hz        : in  std_logic;
            rst            : in  std_logic;
            button0_pulse  : in  std_logic;
            status         : out std_logic_vector(3 downto 0)
        );
    end component;

    component time_counters is
        Port (
            clk10hz        : in  std_logic;
            rst            : in  std_logic;
            status         : in  std_logic_vector(3 downto 0);
            button1_pulse  : in  std_logic;

            HD             : out std_logic_vector(3 downto 0);
            HU             : out std_logic_vector(3 downto 0);
            MD             : out std_logic_vector(3 downto 0);
            MU             : out std_logic_vector(3 downto 0);
            SD             : out std_logic_vector(3 downto 0);
            SU             : out std_logic_vector(3 downto 0);
            ST             : out std_logic_vector(3 downto 0)
        );
    end component;

    component display_driver is
        Port (
            HD        : in  std_logic_vector(3 downto 0);
            HU        : in  std_logic_vector(3 downto 0);
            MD        : in  std_logic_vector(3 downto 0);
            MU        : in  std_logic_vector(3 downto 0);
            SD        : in  std_logic_vector(3 downto 0);
            SU        : in  std_logic_vector(3 downto 0);
            ST        : in  std_logic_vector(3 downto 0);

            clk1khz   : in  std_logic;
            status    : in  std_logic_vector(3 downto 0);
            button1   : in  std_logic;
            alarm_on  : in  std_logic;

            an        : out std_logic_vector(3 downto 0);
            seg       : out std_logic_vector(6 downto 0)
        );
    end component;

begin

    -- Instantiate clock divider
    u_clk_div: clock_divider
        port map (
            clk      => clk,
            rst      => rst,
            clk10hz  => clk10hz_sig,
            clk1khz  => clk1khz_sig
        );

    u_button_sync: button_sync
        port map (
            clk10hz       => clk10hz_sig,
            rst           => rst,

            button0_in    => b0,        -- Basys button b1
            button1_in    => b1,        -- Basys button b2
            button2_in    => '0',       -- unused yet
            button3_in    => '0',       -- unused yet

            button0_pulse => button0_pulse,
            button1_pulse => button1_pulse,
            button0_raw   => button0_raw,
            button2_pulse => button2_pulse,
            button3_pulse => button3_pulse
        );

    u_mode_fsm: mode_fsm
        port map (
            clk10hz        => clk10hz_sig,
            rst            => rst,
            button0_pulse  => button0_pulse,
            status         => status
        );
    
    u_time_cnt: time_counters
        port map (
            clk10hz        => clk10hz_sig,
            rst            => rst,
            status         => status,
            button1_pulse  => button1_pulse,

            HD => HD, HU => HU,
            MD => MD, MU => MU,
            SD => SD, SU => SU,
            ST => ST
        );

    u_display: display_driver
        port map (
            HD      => HD,
            HU      => HU,
            MD      => MD,
            MU      => MU,
            SD      => SD,
            SU      => SU,
            ST      => ST,

            clk1khz => clk1khz_sig,
            status  => status,
            button1 => b1,
            alarm_on => '0',

            an      => an,
            seg     => seg
        );

end Behavioral;