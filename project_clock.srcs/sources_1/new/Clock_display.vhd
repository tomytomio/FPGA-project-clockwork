library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity display_state_controller is
    Port (
        clk       : in  std_logic;  -- main clock (e.g., 100 MHz)
        clk_blink : in  std_logic;  -- slow clock for blinking (e.g., 2 Hz)
        rst       : in  std_logic;
        b1        : in  std_logic;  -- button to switch states
        b2        : in  std_logic;  
        seg       : out std_logic_vector(6 downto 0); -- segments a to g
        an        : out std_logic_vector(3 downto 0)  -- digit enable (active low)
    );
end display_state_controller;

architecture Behavioral of display_state_controller is

    type state_type is (ALL_ON, ALL_OFF, BLINK);
    signal current_state : state_type := ALL_ON;

    signal b1_prev : std_logic := '0';
    signal blink_toggle : std_logic := '0';

begin

    -- Button press detection (rising edge)
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                current_state <= ALL_ON;
                b1_prev <= '0';
            else
                if b1 = '1' and b1_prev = '0' then  -- rising edge
                    case current_state is
                        when ALL_ON   => current_state <= ALL_OFF;
                        when ALL_OFF  => current_state <= BLINK;
                        when BLINK    => current_state <= ALL_ON;
                    end case;
                end if;
                b1_prev <= b1;
            end if;
        end if;
    end process;

    -- Blinking toggle (driven by slow clock)
    process(clk_blink)
    begin
        if rising_edge(clk_blink) then
            blink_toggle <= not blink_toggle;
        end if;
    end process;

    -- Segment control based on state
    process(current_state, blink_toggle)
    begin
        case current_state is
            when ALL_ON =>
                seg <= "0000000";  -- all segments ON
            when ALL_OFF =>
                seg <= "1111111";  -- all segments OFF
            when BLINK =>
                if blink_toggle = '1' then
                    seg <= "0000000";  -- ON
                else
                    seg <= "1111111";  -- OFF
                end if;
        end case;
        an <= "0000";  -- enable all digits
    end process;

end Behavioral;