-------------------------------------------------------------------------------
--                                                                      
--                        Final Project: Calculator
--  
-------------------------------------------------------------------------------
--                                                                      
-- ENTITY:         alu
--
-- FILENAME:       alu_.vhd
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
-- DESCRIPTION:    This is the entity declaration of the alu sub-unit
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
-- CHANGES:       (none)
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity alu is
  port (
    clk_i      : in std_logic; --System clock
      reset_i    : in std_logic; --Asynchronous high active reset
      op1_i      : in std_logic_vector(11 downto 0); -- 12-bit operand OP1 for ALU
      op2_i      : in std_logic_vector(11 downto 0); -- 12-bit operand OP2 for ALU
      optype_i   : in std_logic_vector(3 downto 0); -- Type of operation for ALU
      start_i    : in std_logic; -- Start signal for ALU
      finished_o : out std_logic; -- ALU indication of calculation finished
      result_o   : out std_logic_vector(15 downto 0); -- 16-bit result of the calculation
      sign_o     : out std_logic; -- Sign bit of the result (0=positive, 1=negative)
      overflow_o : out std_logic; -- Overflow indication of the calculation
      error_o    : out std_logic); -- Error indication of the calculation
end alu;
