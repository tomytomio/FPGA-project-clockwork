library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top is
    Port (
        clk    : in  std_logic;  -- 100 MHz clock from Basys 3
        rst    : in  std_logic;
        clk10hz  : out std_logic;
        clk1khz  : out std_logic;
        b1     : in  std_logic;
        b2     : in  std_logic;
        seg    : out std_logic_vector(6 downto 0);
        an     : out std_logic_vector(3 downto 0)
        
    );
end top;

architecture Behavioral of top is

    -- Internal signals
    signal clk1khz_sig : std_logic;
    signal clk10hz_sig : std_logic;

    -- Component declarations
    component clock_divider
        Port (
            clk      : in  std_logic;
            rst      : in  std_logic;
            clk10hz  : out std_logic;
            clk1khz  : out std_logic
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
    clk10Hz<=clk10Hz_sig;
    clk1kHz<=clk1kHz_sig;

end Behavioral;