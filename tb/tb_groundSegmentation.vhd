library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

use work.ground_types_pkg.all;

entity tb_groundSegmentation is
end entity;

architecture sim of tb_groundSegmentation is

    -- DUT signals 
    signal R_tb          : u16_matrix;
    signal groundMask_tb : sl_matrix;

    -- Matrix initialization type and constant
    type int_matrix is array (0 to 23, 0 to 23) of integer;

    -- Initial test input hardcoded as integer matrix
    constant R_INIT_INT : int_matrix := (
        (5000,5000,5000,5000,5000,5000,5000,5000,5000,5500,5500,5500,5500,5500,5500,5000,5000,5000,5000,5000,5000,5000,5000,5000),
        (5000,5000,5000,5000,5000,5000,5000,5000,5000,5500,5500,5500,5500,5500,5500,5000,5000,5000,5000,5000,5000,5000,5000,5000),
        (5000,5000,5000,5000,5000,5000,5000,5000,5000,5500,5500,5500,5500,5500,5500,5000,5000,5000,5000,5000,5000,5000,5000,5000),
        (5000,5000,5000,5000,5000,5000,5000,5000,5000,5500,5500,5500,5500,5500,5500,5000,5000,5000,5000,5000,5000,5000,5000,5000),
        (5000,5000,819,5000,5000,5000,5000,5000,5000,5500,5500,5500,5500,5500,5500,5000,5000,5000,5000,5000,5000,819,5000,5000),
        (5000,5000,800,5000,5000,5000,5000,5000,5000,5500,5500,5500,5500,5500,5500,5000,5000,5000,5000,5000,5000,800,5000,5000),
        (5000,5000,780,5000,5000,5000,5000,5000,5000,5500,5500,5500,5500,5500,5500,5000,5000,5000,5000,5000,5000,780,5000,5000),
        (5000,5000,760,5000,5000,5000,5000,5000,5000,5500,5500,5500,5500,5500,5500,5000,5000,5000,5000,5000,5000,760,5000,5000),
        (5000,5000,740,5000,5000,5000,5000,5000,5000,5500,5500,5500,5500,5500,5500,5000,5000,5000,5000,5000,5000,740,5000,5000),
        (5000,5000,720,5000,5000,5000,5000,5000,5000,5500,5500,1120,1120,5500,5500,5000,5000,5000,5000,5000,5000,720,5000,5000),
        (5000,5000,700,5000,5000,5000,5000,5000,5000,5500,5500,1090,1090,5500,5500,5000,5000,5000,5000,5000,5000,700,5000,5000),
        (5000,5000,680,5000,5000,5000,5000,5000,5000,5500,5500,1060,1060,5500,5500,5000,5000,5000,5000,5000,5000,680,5000,5000),
        (5000,5000,660,5000,5000,5000,5000,5000,5000,5500,5500,1030,1030,5500,5500,5000,5000,5000,5000,5000,5000,660,5000,5000),
        (5069,5069,640,5069,5069,5069,5069,5069,5069,5576,5576,1000,1000,5576,5576,5069,5069,5069,5069,5069,5069,640,5069,5069),
        (3042,3042,620,3042,3042,3042,3042,3042,3042,3346,3346,3346,3346,3346,3346,3042,3042,3042,3042,3042,3042,620,3042,3042),
        (2173,2173,600,2173,2173,2173,2173,2173,2173,2391,2391,2391,2391,2391,2391,2173,2173,2173,2173,2173,2173,600,2173,2173),
        (1691,1691,1691,1691,1691,1691,1691,1691,1691,1860,1860,1860,1860,1860,1860,1691,1691,1691,1691,1691,1691,1691,1691,1691),
        (1385,1385,1385,1385,1385,1385,1385,1385,1385,1523,1523,1523,1523,1523,1523,1385,1385,1385,1385,1385,1385,1385,1385,1385),
        (1172,1172,1172,1172,1172,1172,1172,1172,1172,1290,1290,1290,1290,1290,1290,1172,1172,1172,1172,1172,1172,1172,1172,1172),
        (1017,1017,1017,1017,1017,1017,1017,1017,1017,1119,1119,1119,1119,1119,1119,1017,1017,1017,1017,1017,1017,1017,1017,1017),
        (898,898,898,898,898,898,898,898,898,988,988,988,988,988,988,898,898,898,898,898,898,898,898,898),
        (804,804,804,804,804,804,804,804,804,885,885,885,885,885,885,804,804,804,804,804,804,804,804,804),
        (729,729,729,729,729,729,729,729,729,802,802,802,802,802,802,729,729,729,729,729,729,729,729,729),
        (670,670,670,670,670,670,670,670,670,733,733,733,733,733,733,670,670,670,670,670,670,670,670,670)
    );

    -- Export procedures
    procedure export_u16_matrix(
        constant fname : in string;
        signal   M     : in u16_matrix
    ) is
        file f : text open write_mode is fname;
        variable L : line;
        variable v : integer;
    begin
        -- Iterate trough matrix 
        for y in 23 downto 0 loop
            for x in 0 to 23 loop
                -- Convert unsigned to integer for writing
                v := to_integer(M(y,x));
                -- Write value to line
                write(L, v);
                -- Add space if not last element
                if x < 23 then write(L, character'(' ')); end if;
            end loop;
            -- Write line to file
            writeline(f, L);
        end loop;
    end procedure;

    -- Export sl_matrix procedure
    procedure export_sl_matrix(
        constant fname : in string;
        signal   M     : in sl_matrix
    ) is
        file f : text open write_mode is fname;
        variable L : line;
    begin
        -- Iterate trough matrix
        for y in 23 downto 0 loop
            for x in 0 to 23 loop
                -- Write '1' or '0' based on std_logic value
                if M(y,x) = '1' then
                    write(L, character'('1'));
                else
                    write(L, character'('0'));
                end if;
                -- Add space if not last element
                if x < 23 then write(L, character'(' ')); end if;
            end loop;
            -- Write line to file
            writeline(f, L);
        end loop;
    end procedure;

begin

    -- DUT instantiation --
    dut: entity work.groundSegmentation
        port map (
            R          => R_tb,
            groundMask => groundMask_tb
        );

    stim_proc: process
    begin
        -- Test 1: simple slope road --
        -- Initialize input matrix with a slope
        for y in 0 to 23 loop
            for x in 0 to 23 loop
                -- Create a slope in range values
                R_tb(y,x) <= to_unsigned(1000 + y*40, 16);
            end loop;
        end loop;

        wait for 40 ns;
        -- Export results to files --
        export_u16_matrix("txt/input_test1_slope.txt", R_tb);
        export_sl_matrix("txt/mask_test1_slope.txt", groundMask_tb);
        -- End of Test 1 --
        report "Test 1 completed." severity note;
        wait for 20 ns;

        -- Test 2: Road with obstacle --
        for y in 0 to 23 loop
            for x in 0 to 23 loop

                -- Obstacle in the middle
                if (x >= 10 and x <= 13) and (y >= 14 and y <= 20) then
                    R_tb(y,x) <= to_unsigned(600, 16);  -- obiect aproape

                -- Rest is slope
                else
                    R_tb(y,x) <= to_unsigned(1000 + y*40, 16);
                end if;

            end loop;
        end loop;

        wait for 40 ns;
        -- Export results to files --
        export_u16_matrix("txt/input_test2_obstacle.txt", R_tb);
        export_sl_matrix("txt/mask_test2_obstacle.txt", groundMask_tb);
        -- End of Test 2 --
        report "Test 2 completed." severity note;
        wait for 20 ns;

        -- Test 3: Simplified car perspective --

        -- Initialize input matrix from constant
        for y in 0 to 23 loop
            for x in 0 to 23 loop
                R_tb(y,x) <= to_unsigned(R_INIT_INT(y,x), 16);      -- Convert integer to unsigned
            end loop;
        end loop;

        wait for 40 ns;

        -- Export results to files --
        export_u16_matrix("txt/input_perspective.txt", R_tb);
        export_sl_matrix ("txt/mask_perspective.txt",  groundMask_tb);

        report "Simulation finished." severity note;
        assert false report "DONE" severity failure;
    end process;

end architecture;
