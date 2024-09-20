-------------------------------------------------------------------------------
--                                                                      
--                        Final Project: Calculator
--  
-------------------------------------------------------------------------------
--                                                                      
-- ENTITY:         tb_io_ctrl
--
-- FILENAME:       tb_io_ctrl_sim.vhd
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
-- DESCRIPTION:    This is the architecture of the io_ctrl sub-unit testbench
--                 for the calculator project. It It generates a clock signal
--                 and tests the io_ctrl unit with different sequences of
--                 input signals.
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

architecture sim of tb_io_ctrl is

  component io_ctrl
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
      pbsync_o : out std_logic_vector(3 downto 0) --State of 4 debounced push buttons
    );
  end component;

  -- Declare the signals used stimulating the design's inputs.
  signal clk_i    : std_logic;
  signal reset_i  : std_logic;
  signal dig0_i   : std_logic_vector(7 downto 0) := (others => '0');
  signal dig1_i   : std_logic_vector(7 downto 0) := (others => '0');
  signal dig2_i   : std_logic_vector(7 downto 0) := (others => '0');
  signal dig3_i   : std_logic_vector(7 downto 0) := (others => '0');
  signal led_i    : std_logic_vector(15 downto 0) := (others => '0');
  signal sw_i     : std_logic_vector(15 downto 0) := (others => '0');
  signal pb_i     : std_logic_vector(3 downto 0) := (others => '0');
  signal ss_o     : std_logic_vector(7 downto 0);
  signal ss_sel_o : std_logic_vector(3 downto 0);
  signal led_o    : std_logic_vector(15 downto 0);
  signal swsync_o : std_logic_vector(15 downto 0);
  signal pbsync_o : std_logic_vector(3 downto 0);
begin

  -- Instantiate the calculator design for testing
  i_io_ctrl : io_ctrl
  port map
  (
    clk_i    => clk_i,
    reset_i  => reset_i,
    dig0_i   => dig0_i,
    dig1_i   => dig1_i,
    dig2_i   => dig2_i,
    dig3_i   => dig3_i,
    led_i    => led_i,
    sw_i     => sw_i,
    pb_i     => pb_i,
    ss_o     => ss_o,
    ss_sel_o => ss_sel_o,
    led_o    => led_o,
    swsync_o => swsync_o,
    pbsync_o => pbsync_o
  );

  -- Generate the clock signal (100MHz)
  p_clk_gen : process
  begin
    clk_i <= '0';
    wait for 5 ns;
    clk_i <= '1';
    wait for 5 ns;
  end process p_clk_gen;

  -- Test the design with different sequences of input signals
  p_test : process
  begin
    --reset sequence
    reset_i <= '1';
    wait for 2 ms;
    reset_i <= '0';
    wait for 1 ms;

    led_i <= "0000000000000001"; --turn on one led
    dig0_i <= "00000001"; --turn on one segment of digit 1
    dig1_i <= "00000010"; --turn on one segment of digit 2
    dig2_i <= "00000100"; --turn on one segment of digit 3
    dig3_i <= "00001000"; --turn on one segment of digit 4

    wait for 1 ms;

    pb_i <= "1000"; --Enter OP1 Button bouncing
    wait for 2 ms; 
    pb_i <= "0000";
    wait for 1 ms;
    pb_i <= "1000";
    wait for 500 us; 
    pb_i <= "0000";
    wait for 250 us;
    pb_i <= "1000";
    wait for 100 us; 
    pb_i <= "0000";
    wait for 100 us;

    pb_i <= "1000"; --Stopped Bouncing
    wait for 7 ms;

    pb_i <= "0000"; --release bouncing
    wait for 2 ms;
    pb_i <= "1000";
    wait for 1 ms;
    pb_i <= "0000";
    wait for 500 us;
    pb_i <= "1000";
    wait for 250 us;
    pb_i <= "0000";
    wait for 100 us;
    pb_i <= "1000";
    wait for 100 us;
    pb_i <= "0000";
 
    sw_i <= "0000000000000001"; --Switch 0 bouncing
    wait for 2 ms;
    sw_i <= "0000000000000000";
    wait for 1 ms;
    sw_i <= "0000000000000001";
    wait for 500 us;
    sw_i <= "0000000000000000";
    wait for 250 us;
    sw_i <= "0000000000000001";
    wait for 100 us;
    sw_i <= "0000000000000000";
    wait for 100 us;
    sw_i <= "0000000000000001";
    wait for 7 ms; --Stopped Bouncing
    sw_i <= "0000000000000000"; --release bouncing
    wait for 2 ms;
    sw_i <= "0000000000000001";
    wait for 1 ms;
    sw_i <= "0000000000000000";
    wait for 500 us;
    sw_i <= "0000000000000001";
    wait for 250 us;
    sw_i <= "0000000000000000";
    wait for 100 us;
    sw_i <= "0000000000000001";
    wait for 100 us;
    sw_i <= "0000000000000000";

    sw_i <= "0000000000000010"; --Switch 1 added
    wait for 7 ms;
    sw_i <= "0000000000000110"; --Switch 1 on, Switch 2 on
    wait for 14 ms;

    assert false report "Testbench finished" severity failure;
  end process p_test;
end sim;