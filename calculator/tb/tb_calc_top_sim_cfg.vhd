-------------------------------------------------------------------------------
--                                                                      
--                        Final Project: Calculator
--  
-------------------------------------------------------------------------------
--                                                                      
-- ENTITY:         tb_calc_top
--
-- FILENAME:       tb_calc_top_sim_cfg.vhd
-- 
-- ARCHITECTURE:   sim
-- 
-- ENGINEER:       Mathias Bohle
--
-- DATE:           10. May 2024
--
-- VERSION:        1.0
--
-------------------------------------------------------------------------------
--                                                                      
-- DESCRIPTION:    This is the configuration for the testbench for the calc_top
--                 module of the calculator project.
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

configuration tb_calc_top_sim_cfg of tb_calc_top is
  for sim
    for i_calc_top : calc_top
      use configuration work.calc_top_struc_cfg;
    end for;
  end for;
end tb_calc_top_sim_cfg;
