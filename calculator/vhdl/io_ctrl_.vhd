-------------------------------------------------------------------------------
--                                                                      
--                        Final Project: Calculator
--  
-------------------------------------------------------------------------------
--                                                                      
-- ENTITY:         io_ctrl
--
-- FILENAME:       io_ctrl_.vhd
-- 
-- ARCHITECTURE:   rtl
-- 
-- ENGINEER:       Mathias Bohle
--
-- DATE:           10. May 2024
--
-- VERSION:        1.0
--
-------------------------------------------------------------------------------
--                                                                      
-- DESCRIPTION:    This is the entity declaration of the io_ctrl sub-unit
--                 of the calculator project.
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

entity io_ctrl is
  port
  (
    clk_i    : in std_logic; --System clock
    reset_i  : in std_logic; --Asynchronous high active reset
    dig0_i   : in std_logic_vector(7 downto 0); --State of 7 segments and decimal point of Digit 0
    dig1_i   : in std_logic_vector(7 downto 0); --State of 7 segments and decimal point of Digit 1
    dig2_i   : in std_logic_vector(7 downto 0); --State of 7 segments and decimal point of Digit 2
    dig3_i   : in std_logic_vector(7 downto 0); --State of 7 segments and decimal point of Digit 3
    led_i    : in std_logic_vector(15 downto 0); --State of the 16 LEDs
    sw_i     : in std_logic_vector(15 downto 0); --State of the 16 switches
    pb_i     : in std_logic_vector(3 downto 0); --State of the 4 push buttons
    ss_o     : out std_logic_vector(7 downto 0); --To the 7-segment digit
    ss_sel_o : out std_logic_vector(3 downto 0); --Selection of 7-segment display
    led_o    : out std_logic_vector(15 downto 0); --To the 16 LEDs
    swsync_o : out std_logic_vector(15 downto 0); --State of 16 debounced switches
    pbsync_o : out std_logic_vector(3 downto 0)); --State of 4 debounced push buttons
end io_ctrl;