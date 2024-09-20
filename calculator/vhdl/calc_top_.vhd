-------------------------------------------------------------------------------
--                                                                      
--                        Final Project: Calculator
--  
-------------------------------------------------------------------------------
--                                                                      
-- ENTITY:         calc_top
--
-- FILENAME:       calc_top_.vhd
-- 
-- ARCHITECTURE:   struc
-- 
-- ENGINEER:       Mathias Bohle
--
-- DATE:           10. May 2024
--
-- VERSION:        1.0
--
-------------------------------------------------------------------------------
--                                                                      
-- DESCRIPTION:    This is the entity declaration of the calculator project 
--                 top-level module. It interfaces with the I/Os of the FPGA.
--
-------------------------------------------------------------------------------
--
-- REFERENCES:     (none)
--
-------------------------------------------------------------------------------
--                                                                      
-- PACKAGES:       std_logic_1164 (IEEE library)
--
-------------------------------------------------------------------------------
--                                                                      
-- CHANGES:        (none)
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity calc_top is
  port
  (
    clk_i    : in std_logic; -- System clock
    reset_i  : in std_logic; -- Asynchronous high active reset
    sw_i     : in std_logic_vector(15 downto 0); -- Connected to 16 switches as inputs
    pb_i     : in std_logic_vector(3 downto 0); -- Connected to 4 push buttons
    ss_o     : out std_logic_vector(7 downto 0); -- Contains values for 4 7-segment digits
    ss_sel_o : out std_logic_vector(3 downto 0); -- To Select one out of four 7-segment digits
    led_o    : out std_logic_vector(15 downto 0)); -- Connected to 16 LEDs
end calc_top;