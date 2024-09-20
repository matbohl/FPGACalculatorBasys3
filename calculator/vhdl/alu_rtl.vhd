-------------------------------------------------------------------------------
--                                                                      
--                        Final Project: Calculator
--  
-------------------------------------------------------------------------------
--                                                                      
-- ENTITY:         alu
--
-- FILENAME:       alu_rtl.vhd
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
-- DESCRIPTION:    This is the architecture rtl of the alu sub-unit
--                 of the calculator project. As per number in attendance list
--                 the alu has to implement the following operations:
--                 ADD, SQUARE, LOGICAL NOT, LOGICAL EXOR.
--
-------------------------------------------------------------------------------
--
-- REFERENCES:     (none)
--
-------------------------------------------------------------------------------
--                                                                      
-- PACKAGES:       std_logic_1164 (IEEE library)
--                 numeric_std (IEEE library)
--
-------------------------------------------------------------------------------
--                                                                      
-- CHANGES:        (none)
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

architecture rtl of alu is

  -- record for output signals of the alu (could be put in a package, but not necessary for this project)
  type r_MUX_OUTPUT is record
    result_o   : std_logic_vector(15 downto 0);
    sign_o     : std_logic;
    error_o    : std_logic;
    overflow_o : std_logic;
    finished_o : std_logic;
  end record;

  --constant for initial output signals
  constant c_MUX_OUTPUT_INIT : r_MUX_OUTPUT := (result_o => (others => '0'),
  sign_o     => '0',
  error_o    => '0',
  overflow_o => '0',
  finished_o => '0');

  --enum for operation
  type t_operation is (ADD_S, SQR_S, NOT_S, EOR_S, NOT_IMPLEMENTED_S);

  --signal for add operation
  signal s_output_add : r_MUX_OUTPUT;

  --signal for square operation
  signal s_output_square : r_MUX_OUTPUT;
  signal s_downcounter   : std_logic_vector(11 downto 0);

  --signal for logical not operation
  signal s_output_not : r_MUX_OUTPUT;

  --signal for logical exor operation
  signal s_output_eor : r_MUX_OUTPUT;

  --signal for not implemented operation
  signal s_output_not_implemented : r_MUX_OUTPUT;

  --signals for mux control  
  signal s_operation : t_operation;

begin

  --synchronous sequential logic: stores the operation during start signal to control mux correctly
  p_operation : process (clk_i, reset_i)
  begin
    if reset_i = '1' then
      s_operation <= NOT_IMPLEMENTED_S;
    elsif rising_edge(clk_i) then
      if start_i = '1' then
        case optype_i is
          when "0000" =>
            s_operation <= ADD_S;
          when "0101" =>
            s_operation <= SQR_S;
          when "1000" =>
            s_operation <= NOT_S;
          when "1011" =>
            s_operation <= EOR_S;
          when others =>
            s_operation <= NOT_IMPLEMENTED_S;
        end case;
      end if;
    end if;

  end process p_operation;

  --combinational logic (all signals in sensitivity list)
  p_mux : process (s_operation, s_output_add, s_output_square, s_output_not, s_output_eor, s_output_not_implemented)
  begin
    case s_operation is
      when ADD_S => --ADD
        result_o   <= s_output_add.result_o;
        sign_o     <= s_output_add.sign_o;
        error_o    <= s_output_add.error_o;
        overflow_o <= s_output_add.overflow_o;
        finished_o <= s_output_add.finished_o;
      when SQR_S => --SQUARE
        result_o   <= s_output_square.result_o;
        sign_o     <= s_output_square.sign_o;
        error_o    <= s_output_square.error_o;
        overflow_o <= s_output_square.overflow_o;
        finished_o <= s_output_square.finished_o;
      when NOT_S => --LOGICAL NOT
        result_o   <= s_output_not.result_o;
        sign_o     <= s_output_not.sign_o;
        error_o    <= s_output_not.error_o;
        overflow_o <= s_output_not.overflow_o;
        finished_o <= s_output_not.finished_o;
      when EOR_S => --LOGICAL EXOR
        result_o   <= s_output_eor.result_o;
        sign_o     <= s_output_eor.sign_o;
        error_o    <= s_output_eor.error_o;
        overflow_o <= s_output_eor.overflow_o;
        finished_o <= s_output_eor.finished_o;
      when others => --NON IMPLEMENTED OPERATOR
        result_o   <= s_output_not_implemented.result_o;
        sign_o     <= s_output_not_implemented.sign_o;
        error_o    <= s_output_not_implemented.error_o;
        overflow_o <= s_output_not_implemented.overflow_o;
        finished_o <= s_output_not_implemented.finished_o;
    end case;
  end process p_mux;

  --synchronous logic with registers
  --sign, error, overflow and result need to be stored, even when op1 and op2 change between different start signals
  --only takes one clock cycle
  p_add : process (clk_i, reset_i)
  begin
    if reset_i = '1' then --asynchronous reset
      s_output_add <= c_MUX_OUTPUT_INIT;
    elsif rising_edge(clk_i) then
      if start_i = '1' then --start calculation
        s_output_add.sign_o     <= '0'; --unsigned + unsigned -> unsigned
        s_output_add.error_o    <= '0';
        s_output_add.overflow_o <= '0'; --2*12bit -> max 13bit
        s_output_add.result_o   <= std_logic_vector(resize(unsigned(op1_i), 16) + resize(unsigned(op2_i), 16));
        s_output_add.finished_o <= '1'; --finished signal
      else
        s_output_add.finished_o <= '0'; --finished signal for only one clock cycle, else 0
      end if;
    end if;
  end process p_add;

  --synchronous logic with registers
  --sign, error, overflow and result need to be stored, even when op1 and op2 change between different start signals
  --takes "op1" clock cycles
  p_square : process (clk_i, reset_i)
  begin
    if reset_i = '1' then --asynchronous reset
      s_output_square <= c_MUX_OUTPUT_INIT;
      s_downcounter   <= (others => '0');
    elsif rising_edge(clk_i) then
      if start_i = '1' then --start calculation
        s_output_square.finished_o <= '0'; --needs multiple clock cycles
        s_output_square.sign_o     <= '0'; --unsigned * unsigned -> unsigned
        s_output_square.error_o    <= '0'; --no error possible
        if op1_i > "000011111111" then --overflow will occur (257*257=66049 -> 1 0000 0010 0000 0001) -> 17bit
          s_output_square.overflow_o <= '1'; --overflow signal
        else
          s_output_square.overflow_o <= '0'; --no overflow signal
        end if;
        s_output_square.result_o <= (others => '0');
        s_downcounter            <= op1_i; --downcounter for sequential adds
      else
        if s_downcounter > "000000000001" then --sequential adds, as long as downcounter is bigger than 1
          s_output_square.result_o <= std_logic_vector(unsigned(s_output_square.result_o) + resize(unsigned(op1_i), 16));
          s_downcounter            <= std_logic_vector(unsigned(s_downcounter) - 1);
        elsif s_downcounter = "000000000001" then --last add -> finished
          s_output_square.result_o   <= std_logic_vector(unsigned(s_output_square.result_o) + resize(unsigned(op1_i), 16));
          s_downcounter              <= std_logic_vector(unsigned(s_downcounter) - 1);
          s_output_square.finished_o <= '1'; --finished signal 
        else
          s_output_square.finished_o <= '0'; --finished signal for only one clock cycle, else 0
        end if;
      end if;
    end if;
  end process p_square;

  --synchronous logic with registers
  --sign, error, overflow and result need to be stored, even when op1 and op2 change between different start signals
  --takes one clock cycle
  p_not : process (clk_i, reset_i)
  begin
    if reset_i = '1' then --asynchronous reset
      s_output_not <= c_MUX_OUTPUT_INIT;
    elsif rising_edge(clk_i) then
      if start_i = '1' then --start calculation
        s_output_not.sign_o     <= '0'; --unsigned -> unsigned
        s_output_not.error_o    <= '0'; --no error possible
        s_output_not.overflow_o <= '0'; --no overflow possible
        s_output_not.result_o   <= std_logic_vector(not(resize((unsigned(op1_i)), 16)));
        s_output_not.finished_o <= '1'; --finished signal
      else
        s_output_not.finished_o <= '0'; --finished signal for only one clock cycle, else 0
      end if;
    end if;
  end process p_not;

  --synchronous logic with registers
  --sign, error, overflow and result need to be stored, even when op1 and op2 change between different start signals
  --takes one clock cycle
  p_eor : process (clk_i, reset_i)
  begin
    if reset_i = '1' then --asynchronous reset
      s_output_eor <= c_MUX_OUTPUT_INIT;
    elsif rising_edge(clk_i) then
      if start_i = '1' then --start calculation
        s_output_eor.sign_o     <= '0'; --unsigned xor unsigned -> unsigned
        s_output_eor.error_o    <= '0'; --no error possible
        s_output_eor.overflow_o <= '0'; --no overflow possible
        s_output_eor.result_o   <= std_logic_vector(resize((unsigned(op1_i xor op2_i)), 16));
        s_output_eor.finished_o <= '1'; --finished signal
      else
        s_output_eor.finished_o <= '0'; --finished signal for only one clock cycle, else 0
      end if;
    end if;
  end process p_eor;

  --synchronous logic with registers
  --sign, error, overflow and result need to be stored, even when op1 and op2 change between different start signals
  --takes one clock cycle
  p_not_implemented : process (clk_i, reset_i)
  begin
    if reset_i = '1' then
      s_output_not_implemented <= c_MUX_OUTPUT_INIT;
    elsif rising_edge(clk_i) then
      if start_i = '1' then
        s_output_not_implemented.sign_o     <= '0'; --error case
        s_output_not_implemented.error_o    <= '1'; --error signal
        s_output_not_implemented.overflow_o <= '0'; --error case
        s_output_not_implemented.result_o   <= (others => '0'); --error case
        s_output_not_implemented.finished_o <= '1'; --finished signal
      else
        s_output_not_implemented.finished_o <= '0'; --finished signal for only one clock cycle, else 0
      end if;
    end if;
  end process p_not_implemented;

end architecture rtl;