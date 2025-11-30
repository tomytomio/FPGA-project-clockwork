library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_sim is
    Port (
        -- Driven by testbench
        clk10hz  : in  std_logic;
        rst      : in  std_logic;

        b1       : in  std_logic;
        b2       : in  std_logic;

        -- Outputs for waveform inspection
        status_o : out std_logic_vector(3 downto 0);
        HD_o     : out std_logic_vector(3 downto 0);
        HU_o     : out std_logic_vector(3 downto 0);
        MD_o     : out std_logic_vector(3 downto 0);
        MU_o     : out std_logic_vector(3 downto 0);
        SD_o     : out std_logic_vector(3 downto 0);
        SU_o     : out std_logic_vector(3 downto 0);
        ST_o     : out std_logic_vector(3 downto 0)
    );
end top_sim;

architecture Behavioral of top_sim is

    -----------------------------------------------------------------
    -- INTERNAL SIGNALS (different names than outputs!)
    -----------------------------------------------------------------
    signal status      : std_logic_vector(3 downto 0);
    signal HD, HU      : std_logic_vector(3 downto 0);
    signal MD, MU      : std_logic_vector(3 downto 0);
    signal SD, SU      : std_logic_vector(3 downto 0);
    signal ST          : std_logic_vector(3 downto 0);

    signal button0_pulse : std_logic;
    signal button1_pulse : std_logic;
    signal button2_pulse : std_logic;
    signal button3_pulse : std_logic;

    signal button1_raw   : std_logic;

    -----------------------------------------------------------------
    -- Component declarations (exact copies)
    -----------------------------------------------------------------
    component button_sync is
        Port (
            clk10hz       : in  std_logic;
            rst           : in  std_logic;
            button0_in    : in  std_logic;
            button1_in    : in  std_logic;
            button2_in    : in  std_logic;
            button3_in    : in  std_logic;

            button0_pulse : out std_logic;
            button1_pulse : out std_logic;
            button1_raw   : out std_logic;
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

begin

    -----------------------------------------------------------------
    -- BUTTON SYNC
    -----------------------------------------------------------------
    u_button_sync: button_sync
        port map (
            clk10hz       => clk10hz,
            rst           => rst,

            button0_in    => b1,       
            button1_in    => b2,
            button2_in    => '0',
            button3_in    => '0',

            button0_pulse => button0_pulse,
            button1_pulse => button1_pulse,
            button1_raw   => button1_raw,
            button2_pulse => button2_pulse,
            button3_pulse => button3_pulse
        );

    -----------------------------------------------------------------
    -- FSM
    -----------------------------------------------------------------
    u_mode_fsm: mode_fsm
        port map (
            clk10hz        => clk10hz,
            rst            => rst,
            button0_pulse  => button0_pulse,
            status         => status
        );

    -----------------------------------------------------------------
    -- TIME COUNTERS
    -----------------------------------------------------------------
    u_time_cnt: time_counters
        port map (
            clk10hz        => clk10hz,
            rst            => rst,
            status         => status,
            button1_pulse  => button1_pulse,

            HD => HD, HU => HU,
            MD => MD, MU => MU,
            SD => SD, SU => SU,
            ST => ST
        );

    -----------------------------------------------------------------
    -- MAP INTERNAL SIGNALS TO OUTPUTS
    -----------------------------------------------------------------
    status_o <= status;
    HD_o <= HD; HU_o <= HU;
    MD_o <= MD; MU_o <= MU;
    SD_o <= SD; SU_o <= SU;
    ST_o <= ST;

end Behavioral;
