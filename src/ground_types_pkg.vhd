library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Package declaration for shared types and constants
package ground_types_pkg is

            -- Global constants --
    constant IMG_H : integer := 24; -- Image height
    constant IMG_W : integer := 24; -- Image width
    constant DATA_W : integer := 16; -- Data width in bits

            -- Type definitions --

    -- Matrix 16x16 of unsigned 16-bit values
    type u16_matrix is array (0 to IMG_H-1, 0 to IMG_W-1) of unsigned(DATA_W-1 downto 0);

    -- Matrix 16x16 of std_logic values
    type sl_matrix is array (0 to IMG_H-1, 0 to IMG_W-1) of std_logic;

end package ground_types_pkg;

package body ground_types_pkg is
end package body ground_types_pkg;
