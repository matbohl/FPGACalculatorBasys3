-------------------------------------------------------------------------------
--                                                                      
--                        Final Project: Calculator
--  
-------------------------------------------------------------------------------
--                                                                      
-- ENTITY:         io_ctrl
--
-- FILENAME:       io_ctrl_rtl.vhd
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
-- DESCRIPTION:    This is the architecture rtl of the io_ctrl sub-unit
--                 of the calculator project.
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

architecture rtl of io_ctrl is

  constant C_ENCOUNTVAL : std_logic_vector(16 downto 0) := "11000011010100000"; --decimal value of 100000 (100MHz/100000 = 1kHz)

  signal s_enctr  : std_logic_vector(16 downto 0); --counter for the enable signal
  signal s_1khzen : std_logic; --1kHz enable signal
  signal s_swsync : std_logic_vector(15 downto 0); --State of 16 debounced switches
  signal s_pbsync : std_logic_vector(3 downto 0); --State of 4 debounced push buttons
  signal s_ss_sel : std_logic_vector(3 downto 0); --Selection of 7-segment display
  signal s_ss     : std_logic_vector(7 downto 0); --Value to be displayed on 7-segment display

  -------------------------------------------------------------------------------
  --       DEBOUNCING WITH SHIFT REGISTER (serial in parallel out)
  --
  --              reg(0)    reg(1)    reg(2)    reg(3)    reg(4)
  --         _____  |  _____  |  _____  |  _____  |  _____  |
  --    IN--|D   Q|-'-|D   Q|-'-|D   Q|-'-|D   Q|-'-|D   Q|-'
  --        |     |   |     |   |     |   |     |   |     |
  --      ;-|CLK  | ;-|CLK  | ;-|CLK  | ;-|CLK  | ;-|CLK  |
  --      |  -----  |  -----  |  -----  |  -----  |  -----   
  --  CLK_|_________!_________!_________!_________!
  --
  -- for push buttons: 
  -- reg: 0 0 0 0 1 -> button was just pushed
  -- 
  -- for switches:
  -- reg: 1 1 1 1 1 -> switch is stable
  -- ----------------------------------------------------------------------------
  
  --signals for debouncing push buttons
  signal s_reg_pb0 : std_logic_vector(4 downto 0);
  signal s_reg_pb1 : std_logic_vector(4 downto 0);
  signal s_reg_pb2 : std_logic_vector(4 downto 0);
  signal s_reg_pb3 : std_logic_vector(4 downto 0);

  --signals for debouncing switches
  signal s_reg_sw0  : std_logic_vector(4 downto 0);
  signal s_reg_sw1  : std_logic_vector(4 downto 0);
  signal s_reg_sw2  : std_logic_vector(4 downto 0);
  signal s_reg_sw3  : std_logic_vector(4 downto 0);
  signal s_reg_sw4  : std_logic_vector(4 downto 0);
  signal s_reg_sw5  : std_logic_vector(4 downto 0);
  signal s_reg_sw6  : std_logic_vector(4 downto 0);
  signal s_reg_sw7  : std_logic_vector(4 downto 0);
  signal s_reg_sw8  : std_logic_vector(4 downto 0);
  signal s_reg_sw9  : std_logic_vector(4 downto 0);
  signal s_reg_sw10 : std_logic_vector(4 downto 0);
  signal s_reg_sw11 : std_logic_vector(4 downto 0);
  signal s_reg_sw12 : std_logic_vector(4 downto 0);
  signal s_reg_sw13 : std_logic_vector(4 downto 0);
  signal s_reg_sw14 : std_logic_vector(4 downto 0);
  signal s_reg_sw15 : std_logic_vector(4 downto 0);

  --Function to shift in a new value into the shift register
  function f_shiftregister_serialin(v_register : in std_logic_vector(4 downto 0); v_newvalue : in std_logic) return std_logic_vector is
    variable v_register_temp : std_logic_vector(4 downto 0);
  begin
    v_register_temp(4 downto 1) := v_register(3 downto 0);
    v_register_temp(0)          := v_newvalue;
    return v_register_temp;
  end function f_shiftregister_serialin;

begin--rtl

  --Generate 1kHz(slow) enable signal
  p_slowen : process (clk_i, reset_i)
  begin
    if reset_i = '1' then --asynchronous reset
      s_enctr  <= (others => '0');
      s_1khzen <= '0';
    elsif rising_edge(clk_i) then
      s_1khzen <= '0';
      if s_enctr < C_ENCOUNTVAL then --As long as the terminal count is not reached: increment the counter.
        s_enctr <= std_logic_vector(unsigned(s_enctr) + 1);
      else
        s_enctr  <= (others => '0'); --terminal count reached: reset the counter and set the enable signal.
        s_1khzen <= '1';
      end if;
    end if;
  end process p_slowen;

  --Debounce buttons and switches
  p_debounce : process (clk_i, reset_i)
  begin
    if reset_i = '1' then
      s_swsync  <= (others => '0');
      s_pbsync  <= (others => '0');
      s_reg_pb0 <= (others => '0');
      s_reg_pb1 <= (others => '0');
      s_reg_pb2 <= (others => '0');
      s_reg_pb3 <= (others => '0');

      s_reg_sw0  <= (others => '0');
      s_reg_sw1  <= (others => '0');
      s_reg_sw2  <= (others => '0');
      s_reg_sw3  <= (others => '0');
      s_reg_sw4  <= (others => '0');
      s_reg_sw5  <= (others => '0');
      s_reg_sw6  <= (others => '0');
      s_reg_sw7  <= (others => '0');
      s_reg_sw8  <= (others => '0');
      s_reg_sw9  <= (others => '0');
      s_reg_sw10 <= (others => '0');
      s_reg_sw11 <= (others => '0');
      s_reg_sw12 <= (others => '0');
      s_reg_sw13 <= (others => '0');
      s_reg_sw14 <= (others => '0');
      s_reg_sw15 <= (others => '0');

    elsif rising_edge(clk_i) then
      if s_1khzen = '1' then
        --shift new values in the shift registers
        --push buttons:
        s_reg_pb0 <= f_shiftregister_serialin(s_reg_pb0, pb_i(0));
        s_reg_pb1 <= f_shiftregister_serialin(s_reg_pb1, pb_i(1));
        s_reg_pb2 <= f_shiftregister_serialin(s_reg_pb2, pb_i(2));
        s_reg_pb3 <= f_shiftregister_serialin(s_reg_pb3, pb_i(3));
        --debounce switches:
        s_reg_sw0  <= f_shiftregister_serialin(s_reg_sw0, sw_i(0));
        if s_reg_sw0 = "11111" then --if the switch is stable
          s_swsync(0) <= '1';
        elsif s_reg_sw0 = "00000" then --if the switch is stable
          s_swsync(0) <= '0';
        end if;

        s_reg_sw1  <= f_shiftregister_serialin(s_reg_sw1, sw_i(1));
        if s_reg_sw1 = "11111" then
          s_swsync(1) <= '1';
        elsif s_reg_sw1 = "00000" then
          s_swsync(1) <= '0';
        end if;

        s_reg_sw2  <= f_shiftregister_serialin(s_reg_sw2, sw_i(2));
        if s_reg_sw2 = "11111" then
          s_swsync(2) <= '1';
        elsif s_reg_sw2 = "00000" then
          s_swsync(2) <= '0';
        end if;

        s_reg_sw3  <= f_shiftregister_serialin(s_reg_sw3, sw_i(3));
        if s_reg_sw3 = "11111" then
          s_swsync(3) <= '1';
        elsif s_reg_sw3 = "00000" then
          s_swsync(3) <= '0';
        end if;

        s_reg_sw4  <= f_shiftregister_serialin(s_reg_sw4, sw_i(4));
        if s_reg_sw4 = "11111" then
          s_swsync(4) <= '1';
        elsif s_reg_sw4 = "00000" then
          s_swsync(4) <= '0';
        end if;

        s_reg_sw5  <= f_shiftregister_serialin(s_reg_sw5, sw_i(5));
        if s_reg_sw5 = "11111" then
          s_swsync(5) <= '1';
        elsif s_reg_sw5 = "00000" then
          s_swsync(5) <= '0';
        end if;
        
        s_reg_sw6  <= f_shiftregister_serialin(s_reg_sw6, sw_i(6));
        if s_reg_sw6 = "11111" then
          s_swsync(6) <= '1';
        elsif s_reg_sw6 = "00000" then
          s_swsync(6) <= '0';
        end if;
        
        s_reg_sw7  <= f_shiftregister_serialin(s_reg_sw7, sw_i(7));
        if s_reg_sw7 = "11111" then
          s_swsync(7) <= '1';
        elsif s_reg_sw7 = "00000" then
          s_swsync(7) <= '0';
        end if;
        
        s_reg_sw8  <= f_shiftregister_serialin(s_reg_sw8, sw_i(8));
        if s_reg_sw8 = "11111" then
          s_swsync(8) <= '1';
        elsif s_reg_sw8 = "00000" then
          s_swsync(8) <= '0';
        end if;
        
        s_reg_sw9  <= f_shiftregister_serialin(s_reg_sw9, sw_i(9));
        if s_reg_sw9 = "11111" then
          s_swsync(9) <= '1';
        elsif s_reg_sw9 = "00000" then
          s_swsync(9) <= '0';
        end if;
        
        s_reg_sw10 <= f_shiftregister_serialin(s_reg_sw10, sw_i(10));
        if s_reg_sw10 = "11111" then
          s_swsync(10) <= '1';
        elsif s_reg_sw10 = "00000" then
          s_swsync(10) <= '0';
        end if; 
        
        s_reg_sw11 <= f_shiftregister_serialin(s_reg_sw11, sw_i(11));
        if s_reg_sw11 = "11111" then
          s_swsync(11) <= '1';
        elsif s_reg_sw11 = "00000" then
          s_swsync(11) <= '0';
        end if;   
        
        s_reg_sw12 <= f_shiftregister_serialin(s_reg_sw12, sw_i(12));
        if s_reg_sw12 = "11111" then
          s_swsync(12) <= '1';
        elsif s_reg_sw12 = "00000" then
          s_swsync(12) <= '0';
        end if;   
        
        s_reg_sw13 <= f_shiftregister_serialin(s_reg_sw13, sw_i(13));
        if s_reg_sw13 = "11111" then
          s_swsync(13) <= '1';
        elsif s_reg_sw13 = "00000" then
          s_swsync(13) <= '0';
        end if;   
        
        s_reg_sw14 <= f_shiftregister_serialin(s_reg_sw14, sw_i(14));
        if s_reg_sw14 = "11111" then
          s_swsync(14) <= '1';
        elsif s_reg_sw14 = "00000" then
          s_swsync(14) <= '0';
        end if; 
        
        s_reg_sw15 <= f_shiftregister_serialin(s_reg_sw15, sw_i(15));
        if s_reg_sw15 = "11111" then
          s_swsync(15) <= '1';
        elsif s_reg_sw15 = "00000" then
          s_swsync(15) <= '0';
        end if;     
      else
        --Output the debounced values
        if s_reg_pb0 = "00001" then --if the button was just pushed
          s_reg_pb0 <= "10001"; --set the button once
          s_pbsync(0) <= '1'; --oneshot signal for debounced button
        elsif s_reg_pb1 = "00001" then
          s_reg_pb1 <= "10001";
          s_pbsync(1) <= '1';
        elsif s_reg_pb2 = "00001" then
          s_reg_pb2 <= "10001";
          s_pbsync(2) <= '1';
        elsif s_reg_pb3 = "00001" then
          s_reg_pb3 <= "10001";
          s_pbsync(3) <= '1';
        else
          s_pbsync <= "0000"; --reset the debounced button signal (after once clk cycle)
        end if;
      end if;
    end if;
  end process p_debounce;

  pbsync_o <= s_pbsync; --output the debounced push button signal
  swsync_o <= s_swsync; --output the debounced switch signal

  --Display controller for the 7-segment display
  p_display_ctrl : process (clk_i, reset_i)
  begin
    if reset_i = '1' then
      s_ss_sel <= (others => '0');
      s_ss     <= (others => '0');
      ss_sel_o <= "1111"; --no 7-segment display selected
      ss_o     <= (others => '0');
    elsif rising_edge(clk_i) then
      --Select the next 7-segment display
      if s_1khzen = '1' then
        case s_ss_sel is
          when "1110" => --select the next 7-segment display (display 2)
            s_ss_sel <= "1101";
            ss_sel_o <= "1101";
            ss_o     <= dig1_i;
          when "1101" => --select the next 7-segment display (display 3)
            s_ss_sel <= "1011";
            ss_sel_o <= "1011";
            ss_o     <= dig2_i;
          when "1011" => --select the next 7-segment display (display 4)
            s_ss_sel <= "0111";
            ss_sel_o <= "0111";
            ss_o     <= dig3_i;
          when "0111" => --select the next 7-segment display (display 1)
            s_ss_sel <= "1110";
            ss_sel_o <= "1110";
            ss_o     <= dig0_i;
          when others => --select 7-segment display 1
            s_ss_sel <= "1110";
            ss_sel_o <= "1110";
            ss_o     <= dig0_i;
        end case;
      end if;

    end if;
  end process p_display_ctrl;

  --Handle the 16 LEDs
  led_o <= led_i;
  
end architecture rtl;