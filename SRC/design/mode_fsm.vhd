library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mode_fsm is
    Port (
        clk10hz        : in  std_logic;
        rst            : in  std_logic;
        button0_pulse  : in  std_logic;
        status         : out std_logic_vector(3 downto 0)
    );
end mode_fsm;

architecture Behavioral of mode_fsm is
    signal mode_reg : integer range 0 to 6 := 0;
begin

process(clk10hz, rst)
begin
    if rst = '1' then
        mode_reg <= 0;

    elsif rising_edge(clk10hz) then
        if button0_pulse = '1' then
            if mode_reg = 6 then
                mode_reg <= 0;
            else
                mode_reg <= mode_reg + 1;
            end if;
        end if;
    end if;
end process;

-- Convert integer mode to 4-bit vector
status <= std_logic_vector(to_unsigned(mode_reg, 4));

end Behavioral;
