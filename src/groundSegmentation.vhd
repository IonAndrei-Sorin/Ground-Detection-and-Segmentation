-- ================================================================
--  Module: groundSegmentation
--  Description:
--  This module implements a ground segmentation algorithm for a
--  16x16 range image. The algorithm classifies each pixel as
--  ground or non-ground based on vertical slope analysis.
--
--  Processing stages:
--   1. Vertical hole filling
--   2. Vertical slope computation (Alpha)
--   3. Ground seed detection
--   4. Iterative flood-fill region growing
--
--  The design is fully combinational and intended for simulation
--  and algorithmic validation.
--
-- For running use in cmd: ghdl -r tb_groundSegmentation --wave=waves.ghw
-- ================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Package containing shared types and constants
use work.ground_types_pkg.all;

-- Entity declaration
entity groundSegmentation is
    port (
        R : in  u16_matrix; -- Input range image
        groundMask : out sl_matrix  -- Output ground mask
    );
end entity;

-- Architecture
architecture rtl of groundSegmentation is

            -- Internal signals --

    -- R_hole: 
    -- Range image after vertical hole filling
    signal R_hole  : u16_matrix;
    -- Alpha:
    -- Vertical slope metric: Alpha(y,x) = |R_hole(y,x) - R_hole(y-1,x)|
    signal Alpha   : u16_matrix;
    -- seedMask:
    -- Initial ground seed mask obtained by bottom-up scan
    signal seedMask: sl_matrix;

            -- Algorithm constants --

    -- Maximum allowed difference between neighbors to fill a vertical hole
    constant HOLE_FILL_MAX_DIFF : unsigned(15 downto 0) := to_unsigned(100,16); -- value = 200 in 16 bits
    -- Maximum slope value for a pixel to be considered a ground seed
    constant SEED_MAX_ALPHA     : unsigned(15 downto 0) := to_unsigned(200,16); -- value = 150 in 16 bits
    -- Maximum slope difference allowed during flood-fill
    constant FLOOD_MAX_DIFF     : unsigned(15 downto 0) := to_unsigned(300,16);  -- value = 50 in 16 bits
    -- Number of flood-fill iterations
    constant ITERATIONS         : integer := 25;

begin

            -- STEP 1 & 2: Vertical hole filling --
    -- Missing pixels (value = 0) are filled using the average of vertical neighbors if their difference is small.
    -- This operation is limited to a vertical band (rows 6..11).
    hole_fill_proc: process(R)
        -- Temporary variable used to compute absolute differences
        variable diff : unsigned(15 downto 0);
    begin
        -- Default behavior: copy input image
        for y in 0 to IMG_H-1 loop  -- Iterate over rows
            for x in 0 to IMG_W-1 loop  -- Iterate over columns
                R_hole(y,x) <= R(y,x);  -- Copy input to output
            end loop;
        end loop;

        -- Apply hole filling only in the central vertical band
        for x in 0 to IMG_W-1 loop  -- Iterate over image columns
            for y in IMG_H/4+1 to (3*IMG_H)/4-1 loop   -- Iterate over image rows 6 to 11 (for 24x24 matrix)
                if R(y,x) = 0 then  -- Check for missing pixel
                    -- Check if both vertical neighbors are valid
                    if (R(y-1,x) /= 0) and (R(y+1,x) /= 0) then
                        diff := unsigned(abs(signed(R(y-1,x)) - signed(R(y+1,x))));   -- Compute absolute difference
                        -- If difference is within threshold, fill the hole
                        if diff < HOLE_FILL_MAX_DIFF then
                            R_hole(y,x) <= (R(y-1,x) + R(y+1,x)) / 2;   -- Fill with average
                        end if;
                    end if;
                end if;
            end loop;
        end loop;
    end process;

            -- STEP 3: Vertical slope computation (Alpha) --
    -- Computes the absolute vertical difference between adjacent pixels. 
    --This metric is used to distinguish ground from obstacles.
    alpha_proc: process(R_hole)
    begin
        -- First row has no upper neighbor
        for x in 0 to IMG_W-1 loop
            Alpha(0,x) <= (others => '0');  -- Set to zero
        end loop;

        -- Compute slope for remaining rows
        for x in 0 to IMG_W-1 loop  -- Iterate over image columns
            for y in 1 to IMG_H-1 loop  -- Iterate over image rows starting from 1
                -- If current or upper pixel is missing
                if (R_hole(y,x) = 0) or (R_hole(y-1,x) = 0) then
                    Alpha(y,x) <= (others => '0');  -- Set alpha to zero
                else
                    Alpha(y,x) <= unsigned(abs(signed(R_hole(y,x)) - signed(R_hole(y-1,x)))); -- Set alpha to absolute difference
                end if;
            end loop;
        end loop;
    end process;

            -- STEP 4: Ground seed detection --
    -- For each column, the algorithm scans bottom-up and selects the first valid pixel with a small slope as a ground seed.
    seed_proc: process(Alpha)
    begin
        -- Clear seed mask
        for y in 0 to IMG_H-1 loop  -- Iterate over image rows
            for x in 0 to IMG_W-1 loop  -- Iterate over image columns
                seedMask(y,x) <= '0';   -- Initialize seed mask to '0'
            end loop;
        end loop;

        -- Bottom-up scan per column
        for x in 0 to IMG_W-1 loop  -- Iterate over image columns
            for y in IMG_H-1 downto IMG_H-2 loop  -- Iterate over rows from bottom to top
                -- If pixel is valid
                if Alpha(y,x) /= 0 then 
                    -- If slope is within seed threshold
                    if Alpha(y,x) <= SEED_MAX_ALPHA then
                        seedMask(y,x) <= '1';  -- Mark as ground seed
                    end if;
                    exit; -- stop at first valid pixel
                end if;
            end loop;
        end loop;
    end process;

            -- STEP 5: Iterative flood-fill region growing --
    -- Starting from the seed mask, the ground region is expanded to neighboring pixels with similar slope values.
    -- Combinational process for flood-fill
    flood_proc: process(seedMask, Alpha)    
        variable mask     : sl_matrix;  -- Current ground mask during iterations
        variable nextMask : sl_matrix;  -- Next ground mask to be computed
    begin
        mask := seedMask;   -- Initialize mask with seedMask

        -- Perform a fixed number of iterations
        for it in 1 to ITERATIONS loop  -- Iterate for a set number of times
            nextMask := mask;   -- Start with current mask

            for y in 0 to IMG_H - 1 loop  -- Iterate over image rows 
                for x in 0 to IMG_W - 1 loop  -- Iterate over image columns
                    -- If current pixel is not ground and is valid
                    if mask(y,x) = '0' and Alpha(y,x) /= 0 then
                        -- Check left neighbor
                        -- If left neighbor is ground and slope difference is within threshold
                        if x>0 and mask(y,x-1) = '1' and abs(signed(Alpha(y,x)) - signed(Alpha(y,x-1))) <= signed(FLOOD_MAX_DIFF) then
                            -- Mark as ground if the left neighbor is ground and slope difference is lesser than threshold
                            nextMask(y,x) := '1';   -- Mark as ground

                        -- Check right neighbor
                        -- If right neighbor is ground and slope difference is within threshold    
                        elsif x < IMG_W - 1 and mask(y,x+1) = '1' and abs(signed(Alpha(y,x)) - signed(Alpha(y,x+1))) <= signed(FLOOD_MAX_DIFF) then
                            nextMask(y,x) := '1';   -- Mark as ground

                        -- Check upper neighbor
                        -- If upper neighbor is ground and slope difference is within threshold
                        elsif y > 0 and mask(y-1,x) = '1' and abs(signed(Alpha(y,x)) - signed(Alpha(y-1,x))) <= signed(FLOOD_MAX_DIFF) then
                            nextMask(y,x) := '1';   -- Mark as ground

                        -- Check lower neighbor
                        -- If lower neighbor is ground and slope difference is within threshold
                        elsif y < IMG_H - 1 and mask(y+1,x) = '1' and abs(signed(Alpha(y,x)) - signed(Alpha(y+1,x))) <= signed(FLOOD_MAX_DIFF) then
                            nextMask(y,x) := '1';  -- Mark as ground
                        end if;

                    end if;
                end loop;
            end loop;

            -- Update mask for next iteration
            mask := nextMask;
        end loop;
    
        -- Output the final ground mask
        groundMask <= mask;
    end process;

end architecture;
