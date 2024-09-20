-------------------------------------------------------------------------------
--                                                                      
--                        Final Project: Calculator
--  
-------------------------------------------------------------------------------
--                                                                      
-- ENTITY:         tb_calc_ctrl
--
-- FILENAME:       tb_calc_ctrl_sim.vhd
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
-- DESCRIPTION:    This is the architecture of the calc_ctrl sub-unit testbench
--                 for the calculator project. It generates a clock signal
--                 and tests the control unit with different sequences.
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

architecture sim of tb_calc_ctrl is

  component calc_ctrl
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
      led_o      : out std_logic_vector(15 downto 0)); -- State of 16 LEDs
  end component;

  -- Declare the signals used stimulating the design's inputs.
  signal clk_i      : std_logic;
  signal reset_i    : std_logic;
  signal swsync_i   : std_logic_vector(15 downto 0) := (others => '0');
  signal pbsync_i   : std_logic_vector(3 downto 0)  := (others => '0');
  signal finished_i : std_logic                     := '0';
  signal result_i   : std_logic_vector(15 downto 0) := (others => '0');
  signal sign_i     : std_logic                     := '0';
  signal overflow_i : std_logic                     := '0';
  signal error_i    : std_logic                     := '0';
  signal op1_o      : std_logic_vector(11 downto 0);
  signal op2_o      : std_logic_vector(11 downto 0);
  signal optype_o   : std_logic_vector(3 downto 0);
  signal start_o    : std_logic;
  signal dig0_o     : std_logic_vector(7 downto 0);
  signal dig1_o     : std_logic_vector(7 downto 0);
  signal dig2_o     : std_logic_vector(7 downto 0);
  signal dig3_o     : std_logic_vector(7 downto 0);
  signal led_o      : std_logic_vector(15 downto 0);

begin

  -- Instantiate the calc_ctrl design for testing
  i_calc_ctrl : calc_ctrl
  port map
  (
    clk_i      => clk_i,
    reset_i    => reset_i,
    swsync_i   => swsync_i,
    pbsync_i   => pbsync_i,
    finished_i => finished_i,
    result_i   => result_i,
    sign_i     => sign_i,
    overflow_i => overflow_i,
    error_i    => error_i,
    op1_o      => op1_o,
    op2_o      => op2_o,
    optype_o   => optype_o,
    start_o    => start_o,
    dig0_o     => dig0_o,
    dig1_o     => dig1_o,
    dig2_o     => dig2_o,
    dig3_o     => dig3_o,
    led_o      => led_o
  );

  -- Generate the clock signal (100MHz)
  p_clk_gen : process
  begin
    clk_i <= '0';
    wait for 5 ns;
    clk_i <= '1';
    wait for 5 ns;
  end process;

  -- Generate the test sequence
  p_test : process
  begin
    --reset sequence
    reset_i <= '1';
    wait for 25 ns;
    reset_i    <= '0';
    finished_i <= '1';
    wait for 10 ns;
    finished_i <= '0';

    --test
    pbsync_i <= "1000"; --Enter OP1 Button pressed
    wait for 10 ns;
    pbsync_i <= "0000";
    wait for 30 ns;

    swsync_i <= "0000000000001101"; --Set OP1 to 1101
    wait for 50 ns;
    assert (dig0_o = "10000101") report "Digit 0 not set correctly" severity failure;
    assert (dig1_o = "00000011") report "Digit 1 not set correctly" severity failure;
    assert (dig2_o = "00000011") report "Digit 2 not set correctly" severity failure;
    assert (dig3_o = "10011110") report "Digit 3 not set correctly" severity failure;
    pbsync_i <= "0100"; --Enter OP2 Button pressed
    wait for 10 ns;
    pbsync_i <= "0000";
    wait for 30 ns;
    assert (op1_o = "000000001101") report "OP1 not set correctly" severity failure;

    swsync_i <= "0000000000000011"; --Set OP2 to 0011
    wait for 50 ns;

    assert (dig0_o = "00001101") report "Digit 0 not set correctly" severity failure;
    assert (dig1_o = "00000011") report "Digit 1 not set correctly" severity failure;
    assert (dig2_o = "00000011") report "Digit 2 not set correctly" severity failure;
    assert (dig3_o = "00100100") report "Digit 3 not set correctly" severity failure;
    pbsync_i <= "0010"; --Enter Operation Button pressed
    wait for 10 ns;
    pbsync_i <= "0000";
    wait for 30 ns;
    assert (op2_o = "000000000011") report "OP2 not set correctly" severity failure;

    swsync_i <= "0000000000000011"; --Set upper Switches to 0000 (Addition)
    wait for 50 ns;

    assert (dig0_o = "10000101") report "Digit 0 not set correctly" severity failure;
    assert (dig1_o = "10000101") report "Digit 1 not set correctly" severity failure;
    assert (dig2_o = "00010001") report "Digit 2 not set correctly" severity failure;
    assert (dig3_o = "11000100") report "Digit 3 not set correctly" severity failure;
    pbsync_i <= "0001"; --Calculate Button pressed
    wait for 10 ns;
    pbsync_i   <= "0000";
    finished_i <= '1';

    assert (optype_o = "0000") report "Operation type not set correctly" severity failure;
    result_i <= "0000000000010000"; --Expected result: 10000
    wait for 10 ns;
    finished_i <= '0';
    wait for 50 ns;

    pbsync_i <= "0010"; --Enter Operation Button pressed
    wait for 10 ns;
    pbsync_i <= "0000";
    wait for 30 ns;

    swsync_i <= "0101000000000011"; --Set upper Switches to 0101 (Square)
    wait for 50 ns;

    pbsync_i <= "0001"; --Calculate Button pressed
    wait for 10 ns;
    pbsync_i <= "0000";
    wait for 100 ns;
    finished_i <= '1';
    result_i   <= "0000000010101001"; --Expected result: 10101001
    wait for 10 ns;
    finished_i <= '0';
    wait for 100 ns;

    assert false report "Testbench finished" severity failure;
  end process;

end sim;