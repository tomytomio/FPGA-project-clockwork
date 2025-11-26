library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package types_pkg is
    subtype digit_t is unsigned(3 downto 0);
    type digit_array is array (3 downto 0) of digit_t;
end package types_pkg;

package body types_pkg is
end package body types_pkg;
