library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity time_counters is
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
end time_counters;

architecture Behavioral of time_counters is

    -- BCD digit registers (0..9 / 0..5 as appropriate)
    signal HD_reg, HU_reg : unsigned(3 downto 0) := (others => '0');
    signal MD_reg, MU_reg : unsigned(3 downto 0) := (others => '0');
    signal SD_reg, SU_reg : unsigned(3 downto 0) := (others => '0');
    signal ST_reg         : unsigned(3 downto 0) := (others => '0');

begin

process(clk10hz, rst)
begin
    if rst = '1' then
        -- Reset time to 00:00:00.0
        HD_reg <= (others => '0');
        HU_reg <= (others => '0');
        MD_reg <= (others => '0');
        MU_reg <= (others => '0');
        SD_reg <= (others => '0');
        SU_reg <= (others => '0');
        ST_reg <= (others => '0');

    elsif rising_edge(clk10hz) then

        -- Time counting functionality
        
        -- Increment tenths
        if ST_reg = to_unsigned(9, 4) then
            ST_reg <= (others => '0');
            -- increment seconds units (SU)
            if SU_reg = to_unsigned(9, 4) then
                SU_reg <= (others => '0');
                -- increment seconds tens (SD)
                if SD_reg = to_unsigned(5, 4) then
                    SD_reg <= (others => '0');
                    -- increment minutes units (MU)
                    if MU_reg = to_unsigned(9, 4) then
                        MU_reg <= (others => '0');
                        -- increment minutes tens (MD)
                        if MD_reg = to_unsigned(5, 4) then
                            MD_reg <= (others => '0');
                            -- increment hours (HD/HU) with 23 -> 00 wrap
                            if (HD_reg = to_unsigned(2,4) and HU_reg = to_unsigned(3,4)) then
                                HD_reg <= (others => '0');
                                HU_reg <= (others => '0');
                            else
                                if HU_reg = to_unsigned(9,4) then
                                    HU_reg <= (others => '0');
                                    HD_reg <= HD_reg + 1;
                                else
                                    HU_reg <= HU_reg + 1;
                                end if;
                            end if;
                        else
                            MD_reg <= MD_reg + 1;
                        end if;
                    else
                        MU_reg <= MU_reg + 1;
                    end if;
                else
                    SD_reg <= SD_reg + 1;
                end if;
            else
                SU_reg <= SU_reg + 1;
            end if;
        else
            ST_reg <= ST_reg + 1;
        end if;

        -- Functionalities based on button press
        if button1_pulse = '1' then
            case status is

                -- Mode 1: increment hour
                when "0001" =>
                    -- increment hours with 23 -> 00 wrap
                    if (HD_reg = to_unsigned(2,4) and HU_reg = to_unsigned(3,4)) then
                        HD_reg <= (others => '0');
                        HU_reg <= (others => '0');
                    else
                        if HU_reg = to_unsigned(9,4) then
                            HU_reg <= (others => '0');
                            HD_reg <= HD_reg + 1;
                        else
                            HU_reg <= HU_reg + 1;
                        end if;
                    end if;

                -- Mode 2: increment minute
                when "0010" =>
                    -- increment minutes with 59 -> 00 wrap
                    if MU_reg = to_unsigned(9,4) then
                        MU_reg <= (others => '0');
                        if MD_reg = to_unsigned(5,4) then
                            MD_reg <= (others => '0');
                        else
                            MD_reg <= MD_reg + 1;
                        end if;
                    else
                        MU_reg <= MU_reg + 1;
                    end if;

                -- Mode 3: reset sec and tenth of sec
                when "0011" =>
                    SD_reg <= (others => '0');
                    SU_reg <= (others => '0');
                    ST_reg <= (others => '0');

                when others =>
                    null;
            end case;
        end if;
    end if;
end process;

    HD <= std_logic_vector(HD_reg);
    HU <= std_logic_vector(HU_reg);
    MD <= std_logic_vector(MD_reg);
    MU <= std_logic_vector(MU_reg);
    SD <= std_logic_vector(SD_reg);
    SU <= std_logic_vector(SU_reg);
    ST <= std_logic_vector(ST_reg);

end Behavioral;
