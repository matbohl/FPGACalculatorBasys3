-------------------------------------------------------------------------------
--                                                                      
--                        Final Project: Calculator
--  
-------------------------------------------------------------------------------
--                                                                      
-- ENTITY:         tb_alu
--
-- FILENAME:       tb_alu_sim_cfg.vhd
-- 
-- ARCHITECTURE:   sim
-- 
-- ENGINEER:       Mathias Bohle
--
-- DATE:           11. May 2024
--
-- VERSION:        1.0
--
-------------------------------------------------------------------------------
--                                                                      
-- DESCRIPTION:    This is the configuration for the alu sub-unit testbench
--                 for the calculator project.
--
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

configuration tb_alu_sim_cfg of tb_alu is
  for sim
    for i_alu : alu
      use configuration work.alu_rtl_cfg;
    end for;
  end for;
end tb_alu_sim_cfg;
