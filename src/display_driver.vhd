library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity display_driver is
    Port (
        HD              : in  std_logic_vector(3 downto 0);  -- dozen hours 0..2
        HU              : in  std_logic_vector(3 downto 0);  -- unit hours 0..9
        MD              : in  std_logic_vector(3 downto 0);  -- dozen minutes 0..5
        MU              : in  std_logic_vector(3 downto 0);  -- unit minutes 0..9
        SD              : in  std_logic_vector(3 downto 0);  -- dozen seconds 0..5
        SU              : in  std_logic_vector(3 downto 0);  -- unit seconds 0..9
        ST              : in  std_logic_vector(3 downto 0);  -- 1/10th seconds 0..9
        clk1khz         : in  std_logic;                     -- refresh clock
        status          : in  std_logic_vector(3 downto 0);  -- mode
        button1         : in  std_logic;
        alarm_on        : in  std_logic;

        an              : out std_logic_vector(3 downto 0);  -- active digit
        seg             : out std_logic_vector(6 downto 0)   -- segments a..g (1 = on)
        
        
    );
end display_driver;

architecture Behavioral of display_driver is

    -- display_digit holds symbol IDs (0..17) for the 4 digits
    type digit_array_t is array (3 downto 0) of std_logic_vector(4 downto 0);
    signal display_digit : digit_array_t := (others => (others => '0'));

    signal digit_select   : integer range 0 to 3 := 0;
    
    
    signal blink_digit      : std_logic_vector(3 downto 0); -- which digits should blink
    signal blink_state      : std_logic := '1'; --1 for light on , 0 otherwise
    
    constant blink_interval : integer := 20;  -- number of clk1khz cycles between blinks
    constant blink_duration : integer := 7;  -- number of cycles the visible phase lasts
    signal blink_counter    : integer range 0 to blink_interval := 0;

    -- symbol -> 7-seg mapping (a b c d e f g), '1' lights segment
    function sym_to_seg(sym: integer) return std_logic_vector is
        variable p : std_logic_vector(6 downto 0) := (others => '0');
    begin
        case sym is
            when 0  => p := "1111110"; -- 0 = 126
            when 1  => p := "0110000"; -- 1 = 48
            when 2  => p := "1101101"; -- 2 = 109
            when 3  => p := "1111001"; -- 3 = 121
            when 4  => p := "0110011"; -- 4 = 51
            when 5  => p := "1011011"; -- 5 = 91
            when 6  => p := "1011111"; -- 6 = 95
            when 7  => p := "1110000"; -- 7 = 112
            when 8  => p := "1111111"; -- 8 = 127
            when 9  => p := "1111011"; -- 9 = 123 
            when 10 => p := "1110111"; -- A = 119
            when 11 => p := "0001110"; -- L = 14
            when 12 => p := "0011101"; -- S = 290
            when 13 => p := "0000111"; -- T = 7 
            when 14 => p := "1001110"; -- O = 78
            when 15 => p := "1001111"; -- f = 79
            when 16 => p := "0000101"; -- n = 5
            when 17 => p := "0000000"; -- _ = 0
            when others => p := "0000000";
        end case;
        return p;
    end function;

begin

    ------------------------------------------------------------------
    -- blink_clock: update blink_counter and blink_state on clk1khz
    ------------------------------------------------------------------
    blink_clock_proc: process(clk1khz)
    begin
        if rising_edge(clk1khz) then 
            if blink_counter = blink_interval then
                blink_counter <= 0;
                blink_state <= '0';
            else
                blink_counter <= blink_counter + 1;
                
                if blink_counter > blink_duration then
                    blink_state <= '1';
                end if;
            end if;   
        end if;
    end process;

    ------------------------------------------------------------------
    -- digit_selection: cycle through 0..3 to multiplex displays
    ------------------------------------------------------------------
    digit_selection_proc: process(clk1khz)
    begin
        if rising_edge(clk1khz) then
            if digit_select = 3 then
                digit_select <= 0;
            else
                digit_select <= digit_select + 1;
            end if;
        end if;
    end process;

    ------------------------------------------------------------------
    -- set_display: decide which symbol ID goes to each 4-digit position
    ------------------------------------------------------------------
    set_display_proc: process(clk1khz)
        variable hd_i, hu_i, md_i, mu_i, sd_i, su_i, st_i : integer;
    begin
        if rising_edge(clk1khz) then
            -- capture numeric inputs as integers
            hd_i := to_integer(unsigned(HD));
            hu_i := to_integer(unsigned(HU));
            md_i := to_integer(unsigned(MD));
            mu_i := to_integer(unsigned(MU));
            sd_i := to_integer(unsigned(SD));
            su_i := to_integer(unsigned(SU));
            st_i := to_integer(unsigned(ST));


            case status is
                when "0000" => -- 0 normal: HH:MM ; if button pressed show SS.T0
                    if button1 = '1' then
                        display_digit(3) <= std_logic_vector(to_unsigned(sd_i, 5));
                        display_digit(2) <= std_logic_vector(to_unsigned(su_i, 5));
                        display_digit(1) <= std_logic_vector(to_unsigned(st_i, 5));
                        display_digit(0) <= std_logic_vector(to_unsigned(0, 5));
                    else
                        display_digit(3) <= std_logic_vector(to_unsigned(hd_i, 5));
                        display_digit(2) <= std_logic_vector(to_unsigned(hu_i, 5));
                        display_digit(1) <= std_logic_vector(to_unsigned(md_i, 5));
                        display_digit(0) <= std_logic_vector(to_unsigned(mu_i, 5));
                    end if;
                    blink_digit <= "0000"; --don't blink

                when "0001" => -- 1 set hour: HH:St (St blinking)
                    display_digit(3) <= std_logic_vector(to_unsigned(hd_i,5));
                    display_digit(2) <= std_logic_vector(to_unsigned(hu_i,5));
                    display_digit(1) <= std_logic_vector(to_unsigned(12,5)); -- 'S' symbol id 12
                    display_digit(0) <= std_logic_vector(to_unsigned(13,5)); -- 'T' symbol id 13
                    blink_digit <= "0011"; -- blink last two digits

                when "0010" => -- 2 set minute: St:MM (St blinking)
                    display_digit(3) <= std_logic_vector(to_unsigned(12,5)); -- S
                    display_digit(2) <= std_logic_vector(to_unsigned(13,5)); -- T
                    display_digit(1) <= std_logic_vector(to_unsigned(md_i,5));
                    display_digit(0) <= std_logic_vector(to_unsigned(mu_i,5));
                    blink_digit <= "1100"; -- blink first two digits

                when "0011" => -- 3 reset: SS:St (St blinking)
                    display_digit(3) <= std_logic_vector(to_unsigned(sd_i,5));
                    display_digit(2) <= std_logic_vector(to_unsigned(su_i,5));
                    display_digit(1) <= std_logic_vector(to_unsigned(12,5)); -- S
                    display_digit(0) <= std_logic_vector(to_unsigned(13,5)); -- T
                    blink_digit <= "0011"; -- blink last two digits

                when "0100" => -- 4 toggle: ALOn / ALOf
                    display_digit(3) <= std_logic_vector(to_unsigned(10,5)); -- A
                    display_digit(2) <= std_logic_vector(to_unsigned(11,5)); -- L
                    display_digit(1) <= std_logic_vector(to_unsigned(14,5)); -- O
                    if alarm_on = '1' then
                        display_digit(0) <= std_logic_vector(to_unsigned(16,5)); -- n
                    else
                        display_digit(0) <= std_logic_vector(to_unsigned(15,5)); -- f
                    end if;
                    blink_digit <= "0000"; --don't blink

                when "0101" => -- 5 set alarm: HH:AL (AL blinking)
                    display_digit(3) <= std_logic_vector(to_unsigned(hd_i,5));
                    display_digit(2) <= std_logic_vector(to_unsigned(hu_i,5));
                    display_digit(1) <= std_logic_vector(to_unsigned(10,5)); -- A
                    display_digit(0) <= std_logic_vector(to_unsigned(11,5)); -- L
                    blink_digit <= "0011"; -- blink last two digits

                when "0110" => -- 6 set alarm: AL:MM (AL blinking)
                    display_digit(3) <= std_logic_vector(to_unsigned(10,5)); -- A
                    display_digit(2) <= std_logic_vector(to_unsigned(11,5)); -- L
                    display_digit(1) <= std_logic_vector(to_unsigned(md_i,5));
                    display_digit(0) <= std_logic_vector(to_unsigned(mu_i,5));
                    blink_digit <= "1100"; -- blink first two digits

                when others =>
                    display_digit(3) <= std_logic_vector(to_unsigned(hd_i,5));
                    display_digit(2) <= std_logic_vector(to_unsigned(hu_i,5));
                    display_digit(1) <= std_logic_vector(to_unsigned(md_i,5));
                    display_digit(0) <= std_logic_vector(to_unsigned(mu_i,5));
                    blink_digit <= "0000"; --don't blink
            end case;

        end if;
    end process set_display_proc;

    ------------------------------------------------------------------
    -- digit_to_segment: map selected display_digit to seg
    ------------------------------------------------------------------
    digit_to_segment_proc: process(digit_select, display_digit, blink_state, blink_digit)
        variable sym_id : integer := 0;
    begin

        -- select symbol for current digit_select
        case digit_select is
            when 0 => sym_id := to_integer(unsigned(display_digit(0)));
            when 1 => sym_id := to_integer(unsigned(display_digit(1)));
            when 2 => sym_id := to_integer(unsigned(display_digit(2)));
            when 3 => sym_id := to_integer(unsigned(display_digit(3)));
        end case;

        -- if blink is required for this digit and blink_state = '0' then blank
        if blink_digit(3-digit_select) = '1' and blink_state = '0' then
            seg <= (others => '0');
        else
            seg <= sym_to_seg(sym_id);
        end if;

        -- drive anodes (active low) for multiplexing
        case digit_select is
            when 0 => an <= "0001"; -- rightmost digit active (an(0) low)
            when 1 => an <= "0010";
            when 2 => an <= "0100";
            when 3 => an <= "1000"; -- leftmost active
        end case;

    end process digit_to_segment_proc;

end Behavioral;
