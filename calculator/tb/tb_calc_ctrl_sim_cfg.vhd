-------------------------------------------------------------------------------
--                                                                      
--                        Final Project: Calculator
--  
-------------------------------------------------------------------------------
--                                                                      
-- ENTITY:         tb_calc_ctrl
--
-- FILENAME:       tb_calc_ctrl_sim_cfg.vhd
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
-- DESCRIPTION:    This is the configuration for the calc_ctrl sub-unit testbench
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

configuration tb_calc_ctrl_sim_cfg of tb_calc_ctrl is
  for sim
    for i_calc_ctrl : calc_ctrl
      use configuration work.calc_ctrl_rtl_cfg;
    end for;
  end for;
end tb_calc_ctrl_sim_cfg;
