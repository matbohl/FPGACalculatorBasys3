-------------------------------------------------------------------------------
--                                                                      
--                        Final Project: Calculator
--  
-------------------------------------------------------------------------------
--                                                                      
-- ENTITY:         calc_ctrl
--
-- FILENAME:       calc_ctrl_rtl.vhd
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
-- DESCRIPTION:    This is the architecture rtl of the calc_ctrl sub-unit
--                 of the calculator project. As per number in the attendance 
--                 list, the calc_ctrl sub-unit implements user interface 
--                 variant B as a FSM. The FSM has the following states:
--                 - ENTER_OP1_S
--                 - ENTER_OP2_S
--                 - ENTER_OPERAND_S
--                 - CALCULATE_RESULT_S
--                 - DISPLAY_RESULT_S
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

architecture rtl of calc_ctrl is
  --State enumerator
  type t_state is (ENTER_OP1_S, ENTER_OP2_S, ENTER_OPERAND_S, CALCULATE_RESULT_S, DISPLAY_RESULT_S);
  signal s_entrystate : t_state;

  -- 7(8) Segment Format: 
  --
  --      =CA=
  --   ||      ||     CA CB CC CD CE CF CG DP
  --   CF      CB
  --   ||      ||     B7 B6 B5 B4 B3 B2 B1 B0
  --      =CG=
  --   ||      ||     [on='0', off='1']
  --   CE      CC
  --   ||      ||
  --      =CD=    (DP)
  --

  -- Binary Format:
  --  Symbol    <=>    Binary
  -- 0-F(hex)   <=>    0 B3 B2 B1 B0
  -- 
  --     n      <=>    1 0001
  --     q      <=>    1 0010
  --     r      <=>    1 0011
  --     o      <=>    1 0100
  --     o.     <=>    1 0101
  --     1.     <=>    1 0110
  --     2.     <=>    1 0111
  --

  --decoder function for 7-segment display
  function f_binary_to_7seg(v_binary : in std_logic_vector(4 downto 0)) return std_logic_vector is
    variable v_7seg                    : std_logic_vector(7 downto 0);
  begin
    case v_binary is
      when "00000" => --0
        v_7seg := "00000011";
      when "00001" => --1
        v_7seg := "10011111";
      when "00010" => --2
        v_7seg := "00100101";
      when "00011" => --3
        v_7seg := "00001101";
      when "00100" => --4
        v_7seg := "10011001";
      when "00101" => --5
        v_7seg := "01001001";
      when "00110" => --6
        v_7seg := "01000001";
      when "00111" => --7
        v_7seg := "00011111";
      when "01000" => --8
        v_7seg := "00000001";
      when "01001" => --9
        v_7seg := "00001001";
      when "01010" => --A
        v_7seg := "00010001";
      when "01011" => --b
        v_7seg := "11000001";
      when "01100" => --c
        v_7seg := "01100011";
      when "01101" => --d
        v_7seg := "10000101";
      when "01110" => --E
        v_7seg := "01100001";
      when "01111" => --F
        v_7seg := "01110001";
      when "10000" => --n
        v_7seg := "11010101";
      when "10001" => --q
        v_7seg := "00011001";
      when "10010" => --r
        v_7seg := "11110101";
      when "10011" => --o
        v_7seg := "11000101";
      when "10100" => --o.
        v_7seg := "11000100";
      when "10101" => --1.
        v_7seg := "10011110";
      when "10110" => --2.
        v_7seg := "00100100";
      when others => --default
        v_7seg := "11111111";
    end case;
    return v_7seg;
  end function f_binary_to_7seg;

begin

  --push button controlled fsm
  p_fsm : process (clk_i, reset_i)
  begin
    if reset_i = '1' then --asynchronous reset
      s_entrystate <= CALCULATE_RESULT_S; --first calculation
    elsif rising_edge(clk_i) then
      case pbsync_i is
        when "1000" => --BTNL pressed
          s_entrystate <= ENTER_OP1_S;
        when "0100" => --BTNC pressed
          s_entrystate <= ENTER_OP2_S;
        when "0010" => --BTNR pressed
          s_entrystate <= ENTER_OPERAND_S;
        when "0001" => --BTND pressed
          s_entrystate <= CALCULATE_RESULT_S;
        when others => --None or multiple Buttons pressed
          if s_entrystate = CALCULATE_RESULT_S then --first pass
            s_entrystate <= DISPLAY_RESULT_S; --display result
          end if;
      end case;
    end if;
  end process p_fsm;

  --display output process
  p_dispout : process (clk_i, reset_i)
  begin
    if reset_i = '1' then
      dig0_o   <= f_binary_to_7seg("11111");
      dig1_o   <= f_binary_to_7seg("11111");
      dig2_o   <= f_binary_to_7seg("11111");
      dig3_o   <= f_binary_to_7seg("11111");
      op1_o    <= (others => '0');
      op2_o    <= (others => '0');
      optype_o <= (others => '0');
      led_o    <= (others => '0');
      start_o  <= '0';
    elsif rising_edge(clk_i) then
      case s_entrystate is
        when ENTER_OP1_S => --display "1." plus 12 bit number from swsync_i
          op1_o   <= swsync_i(11 downto 0); --store operand 1
          dig0_o  <= f_binary_to_7seg(std_logic_vector(resize(unsigned(swsync_i(3 downto 0)), 5)));
          dig1_o  <= f_binary_to_7seg(std_logic_vector(resize(unsigned(swsync_i(7 downto 4)), 5)));
          dig2_o  <= f_binary_to_7seg(std_logic_vector(resize(unsigned(swsync_i(11 downto 8)), 5)));
          dig3_o  <= f_binary_to_7seg("10101"); --"1."
          led_o   <= (others => '0'); --all LEDs off
          start_o <= '0';
        when ENTER_OP2_S => --display "2." plus 12 bit number from swsync_i
          op2_o   <= swsync_i(11 downto 0); --store operand 2
          dig0_o  <= f_binary_to_7seg(std_logic_vector(resize(unsigned(swsync_i(3 downto 0)), 5)));
          dig1_o  <= f_binary_to_7seg(std_logic_vector(resize(unsigned(swsync_i(7 downto 4)), 5)));
          dig2_o  <= f_binary_to_7seg(std_logic_vector(resize(unsigned(swsync_i(11 downto 8)), 5)));
          dig3_o  <= f_binary_to_7seg("10110");--"2."
          led_o   <= (others => '0'); --all LEDs off
          start_o <= '0';
        when ENTER_OPERAND_S => --display "o." plus operand type (e.g. Add, Sqr, no, Eor or "   ")
          optype_o <= swsync_i(15 downto 12); --store operand type
          dig3_o   <= f_binary_to_7seg("10100"); --"o."
          start_o  <= '0';
          case swsync_i(15 downto 12) is
            when "0000" => --ADD
              optype_o <= "0000";
              dig2_o   <= f_binary_to_7seg("01010");--"A"
              dig1_o   <= f_binary_to_7seg("01101");--"d"
              dig0_o   <= f_binary_to_7seg("01101");--"d"
            when "0101" => --SQUARE
              optype_o <= "0101";
              dig2_o   <= f_binary_to_7seg("00101");--"S"
              dig1_o   <= f_binary_to_7seg("10001");--"q"
              dig0_o   <= f_binary_to_7seg("10010");--"r"
            when "1000" => --NOT
              optype_o <= "1000";
              dig2_o   <= f_binary_to_7seg("11111");--" "
              dig1_o   <= f_binary_to_7seg("10000");--"n"
              dig0_o   <= f_binary_to_7seg("10011");--"o"
            when "1011" => --EXOR
              optype_o <= "1011";
              dig2_o   <= f_binary_to_7seg("01110");--"E"
              dig1_o   <= f_binary_to_7seg("10011");--"o"
              dig0_o   <= f_binary_to_7seg("10010");--"r"
            when others => --NOT IMPLEMENTED
              optype_o <= "1111";
              dig2_o   <= f_binary_to_7seg("11111");--" "
              dig1_o   <= f_binary_to_7seg("11111");--" "
              dig0_o   <= f_binary_to_7seg("11111");--" "
          end case;
          led_o <= (others        => '0'); --all LEDs off
        when CALCULATE_RESULT_S =>
          start_o <= '1';
        when DISPLAY_RESULT_S =>
          start_o <= '0';
          if finished_i = '1' then
            if error_i = '1' then
              dig3_o <= f_binary_to_7seg("01110");--"E"
              dig2_o <= f_binary_to_7seg("10010");--"r"
              dig1_o <= f_binary_to_7seg("10010");--"r"
              dig0_o <= f_binary_to_7seg("11111");--" "
            elsif overflow_i = '1' then
              dig0_o <= f_binary_to_7seg("10011");--"o"
              dig1_o <= f_binary_to_7seg("10011");--"o"
              dig2_o <= f_binary_to_7seg("10011");--"o"
              dig3_o <= f_binary_to_7seg("10011");--"o"
            elsif sign_i = '1' then
              dig3_o <= "11111101"; --"-"
              dig0_o <= f_binary_to_7seg(std_logic_vector(resize(unsigned(result_i(3 downto 0)), 5)));
              dig1_o <= f_binary_to_7seg(std_logic_vector(resize(unsigned(result_i(7 downto 4)), 5)));
              dig2_o <= f_binary_to_7seg(std_logic_vector(resize(unsigned(result_i(11 downto 8)), 5)));
            else
              dig0_o <= f_binary_to_7seg(std_logic_vector(resize(unsigned(result_i(3 downto 0)), 5)));
              dig1_o <= f_binary_to_7seg(std_logic_vector(resize(unsigned(result_i(7 downto 4)), 5)));
              dig2_o <= f_binary_to_7seg(std_logic_vector(resize(unsigned(result_i(11 downto 8)), 5)));
              dig3_o <= f_binary_to_7seg(std_logic_vector(resize(unsigned(result_i(15 downto 12)), 5)));
            end if;
            led_o <= (15 => '1', others => '0');
          end if;
        when others => --Non reachable state
          dig3_o  <= f_binary_to_7seg("01110");--"E"
          dig2_o  <= f_binary_to_7seg("10010");--"r"
          dig1_o  <= f_binary_to_7seg("10010");--"r"
          dig0_o  <= f_binary_to_7seg("10011");--"o"
          led_o   <= (others => '0');
          start_o <= '0';
      end case;
    end if;
  end process p_dispout;
end architecture rtl;