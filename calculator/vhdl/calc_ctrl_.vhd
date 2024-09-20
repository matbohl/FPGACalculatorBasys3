-------------------------------------------------------------------------------
--                                                                      
--                        Final Project: Calculator
--  
-------------------------------------------------------------------------------
--                                                                      
-- ENTITY:         calc_ctrl
--
-- FILENAME:       calc_ctrl_.vhd
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
-- DESCRIPTION:    This is the entity declaration of the calc_ctrl sub-unit
--                 of the calculator project
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

entity calc_ctrl is
  port
  (
    clk_i      : in std_logic; --System clock
    reset_i    : in std_logic; --Asynchronous high active reset
    swsync_i   : in std_logic_vector(15 downto 0); --State of 16 debounced switches
    pbsync_i   : in std_logic_vector(3 downto 0); --State of 4 debounced push buttons
    finished_i : in std_logic; --ALU indication of calculation finished
    result_i   : in std_logic_vector(15 downto 0); -- 16-bit result of the calculation
    sign_i     : in std_logic; -- Sign bit of the result (0=positive, 1=negative)
    overflow_i : in std_logic; -- Overflow indication of the calculation
    error_i    : in std_logic; -- Error indication of the calculation
    op1_o      : out std_logic_vector(11 downto 0); -- 12-bit operand OP1 for ALU
    op2_o      : out std_logic_vector(11 downto 0); -- 12-bit operand OP2 for ALU
    optype_o   : out std_logic_vector(3 downto 0); -- Type of operation for ALU
    start_o    : out std_logic; -- Start signal for ALU
    dig0_o     : out std_logic_vector(7 downto 0); -- State of 7 segments and decimal point of Digit 0
    dig1_o     : out std_logic_vector(7 downto 0); -- State of 7 segments and decimal point of Digit 1
    dig2_o     : out std_logic_vector(7 downto 0); -- State of 7 segments and decimal point of Digit 2
    dig3_o     : out std_logic_vector(7 downto 0); -- State of 7 segments and decimal point of Digit 3
    led_o      : out std_logic_vector(15 downto 0)); --State of the 16 LEDs
end calc_ctrl;