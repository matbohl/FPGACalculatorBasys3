-------------------------------------------------------------------------------
--                                                                      
--                        Final Project: Calculator
--  
-------------------------------------------------------------------------------
--                                                                      
-- ENTITY:         calc_top
--
-- FILENAME:       calc_top_struc.vhd
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
-- DESCRIPTION:    This is the architecture struc of the calculator project top
--                 level module. It directly interfaces with the I/O pins of 
--                 the FPGA and connects all sub-units of the design.
--                 It consists of the following three sub-units:
--                  -io_ctrl: Handles the I/Os of the calculator.
--                  -alu: Arithmetic logic unit of the calculator.
--                  -calc_ctrl: Main control unit of the calculator.
--
--                -----------------------------------------------------
--               |                       calc_top                      |
--               |   -------------    -------------    -------------   |
--               |  |             |  |             |  |             |  |
--               |  |     alu     |  |  calc_ctrl  |  |   io_ctrl   |  |
--               |  |             |  |             |  |             |  |
--               |   -------------    -------------    -------------   |
--                -----------------------------------------------------
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

architecture struc of calc_top is
  -- Declare the sub-units used in the top level module.
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
      ss_sel_o : out std_logic_vector(3 downto 0); --Selection of 7-segment
      led_o    : out std_logic_vector(15 downto 0); --To the 16 LEDs
      swsync_o : out std_logic_vector(15 downto 0); --State of 16 debounced switches
      pbsync_o : out std_logic_vector(3 downto 0)); --State of 4 debounced push buttons
  end component;

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
      led_o      : out std_logic_vector(15 downto 0)); --State of the 16 LEDs
  end component;

  component alu
    port
    (
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
  end component;

  -- Declare the signals used for interconnection of the sub-units.
  signal s_swsync : std_logic_vector(15 downto 0);
  signal s_pbsync : std_logic_vector(3 downto 0);
  signal s_dig0 : std_logic_vector(7 downto 0);
  signal s_dig1 : std_logic_vector(7 downto 0);
  signal s_dig2 : std_logic_vector(7 downto 0);
  signal s_dig3 : std_logic_vector(7 downto 0);
  signal s_led : std_logic_vector(15 downto 0);
  signal s_start : std_logic;
  signal s_finished : std_logic;
  signal s_result : std_logic_vector(15 downto 0);
  signal s_sign : std_logic;
  signal s_overflow : std_logic;
  signal s_error : std_logic;
  signal s_op1 : std_logic_vector(11 downto 0);
  signal s_op2 : std_logic_vector(11 downto 0);
  signal s_operation : std_logic_vector(3 downto 0);

begin --struct

  -- Instantiate the io_ctrl sub-unit, which is connected to the calc_ctrl sub-unit
  -- and the physical IOs
  i_io_ctrl : io_ctrl
  port map
  (
    clk_i    => clk_i,
    reset_i  => reset_i,
    swsync_o => s_swsync,
    pbsync_o => s_pbsync,
    sw_i     => sw_i,
    pb_i     => pb_i,
    dig0_i   => s_dig0,
    dig1_i   => s_dig1,
    dig2_i   => s_dig2,
    dig3_i   => s_dig3,
    led_i    => s_led,
    ss_o     => ss_o,
    ss_sel_o => ss_sel_o,
    led_o    => led_o
  );

  -- Instantiate the calc_ctrl sub-unit, which is connected to the io_ctrl sub-unit
  -- and the alu sub-unit
  i_calc_ctrl : calc_ctrl
  port map
  (
    clk_i      => clk_i,
    reset_i    => reset_i,
    swsync_i   => s_swsync,
    pbsync_i   => s_pbsync,
    start_o   => s_start,
    finished_i => s_finished,
    result_i   => s_result,
    sign_i     => s_sign,
    overflow_i => s_overflow,
    error_i    => s_error,
    op1_o      => s_op1,
    op2_o      => s_op2,
    optype_o   => s_operation,
    dig0_o     => s_dig0,
    dig1_o     => s_dig1,
    dig2_o     => s_dig2,
    dig3_o     => s_dig3,
    led_o      => s_led
  );

  -- Instantiate the alu sub-unit, which is connected to the calc_ctrl sub-unit
  i_alu : alu
  port map
  (
    clk_i      => clk_i,
    reset_i    => reset_i,
    op1_i      => s_op1,
    op2_i      => s_op2,
    optype_i   => s_operation,
    start_i    => s_start,
    finished_o => s_finished,
    result_o   => s_result,
    sign_o     => s_sign,
    overflow_o => s_overflow,
    error_o    => s_error
  );

end struc;