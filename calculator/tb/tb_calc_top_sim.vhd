-------------------------------------------------------------------------------
--                                                                      
--                        Final Project: Calculator
--  
-------------------------------------------------------------------------------
--                                                                      
-- ENTITY:         tb_calc_top
--
-- FILENAME:       tb_calc_top_sim.vhd
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
-- DESCRIPTION:    This is the architecture of the calc_top testbench
--                 for the calculator project. It generates a clock signal
--                 and tests the whole calculator project with a sequence of
--                 different operations.
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

architecture sim of tb_calc_top is

  component calc_top
    port
    (
      clk_i    : in std_logic; -- System clock
      reset_i  : in std_logic; -- Asynchronous high active reset
      sw_i     : in std_logic_vector(15 downto 0); -- Connected to 16 switches as inputs
      pb_i     : in std_logic_vector(3 downto 0); -- Connected to 4 push buttons
      ss_o     : out std_logic_vector(7 downto 0); -- Contains values for 4 7-segment digits
      ss_sel_o : out std_logic_vector(3 downto 0); -- To Select one out of four 7-segment digits
      led_o    : out std_logic_vector(15 downto 0)); -- Connected to 16 LEDs
  end component;

  -- Declare the signals used stimulating the design's inputs.
  signal clk_i    : std_logic;
  signal reset_i  : std_logic;
  signal sw_i     : std_logic_vector(15 downto 0) := "0000000000000000";
  signal pb_i     : std_logic_vector(3 downto 0) := "0000";
  signal ss_o     : std_logic_vector(7 downto 0) := "00000000";
  signal ss_sel_o : std_logic_vector(3 downto 0) := "0000";
  signal led_o    : std_logic_vector(15 downto 0) := "0000000000000000";

begin

  -- Instantiate the calculator design for testing
  i_calc_top : calc_top
  port map
  (
    clk_i    => clk_i,
    reset_i  => reset_i,
    sw_i     => sw_i,
    pb_i     => pb_i,
    ss_o     => ss_o,
    ss_sel_o => ss_sel_o,
    led_o    => led_o);

  -- Generate the clock signal (100MHz)
  p_clk_gen : process
  begin
    clk_i <= '0';
    wait for 5 ns;
    clk_i <= '1';
    wait for 5 ns;
  end process p_clk_gen;

  -- Stimulate the design's inputs
  p_test : process
  begin
    --reset sequence
    reset_i <= '1';
    wait for 2 ms;
    reset_i <= '0';
    wait for 2 ms;
    
    --test
    pb_i <= "1000"; --Enter OP1 Button pressed
    wait for 2 ms; 
    pb_i <= "0000";

    sw_i <= "0000000000001101"; --Set OP1 to 1101
    wait for 5 ms;

    pb_i <= "0100"; --Enter OP2 Button pressed
    wait for 2 ms;
    pb_i <= "0000";

    sw_i <= "0000000000000011"; --Set OP2 to 0011
    wait for 5 ms;

    pb_i <= "0010"; --Enter Operation Button pressed
    wait for 2 ms;
    pb_i <= "0000";

    sw_i <= "0000000000000011"; --Set upper Switches to 0000 (Addition)
    wait for 5 ms;

    pb_i <= "0001"; --Calculate Button pressed
    wait for 2 ms;
    pb_i <= "0000";

    wait for 10 ms;

    assert false report "Testbench finished" severity failure;
  end process p_test;

end sim;