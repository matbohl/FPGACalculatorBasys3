-------------------------------------------------------------------------------
--                                                                      
--                        Final Project: Calculator
--  
-------------------------------------------------------------------------------
--                                                                      
-- ENTITY:         tb_alu
--
-- FILENAME:       tb_alu_sim.vhd
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
-- DESCRIPTION:    This is the architecture of the alu sub-unit testbench
--                 for the calculator project. It generates a clock signal
--                 and tests the alu with different operations.
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
use IEEE.numeric_std.all;

architecture sim of tb_alu is

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
      error_o    : out std_logic -- Error indication of the calculation
    );
  end component;

  -- Declare the signals used stimulating the design's inputs.
  signal clk_i      : std_logic;
  signal reset_i    : std_logic;
  signal op1_i      : std_logic_vector(11 downto 0) := "000000000000";
  signal op2_i      : std_logic_vector(11 downto 0) := "000000000000";
  signal optype_i   : std_logic_vector(3 downto 0)  := "0000";
  signal start_i    : std_logic                     := '0';
  signal finished_o : std_logic;
  signal result_o   : std_logic_vector(15 downto 0);
  signal sign_o     : std_logic;
  signal overflow_o : std_logic;
  signal error_o    : std_logic;
begin

  -- Instantiate the alu design for testing
  i_alu : alu
  port map
  (
    clk_i      => clk_i,
    reset_i    => reset_i,
    op1_i      => op1_i,
    op2_i      => op2_i,
    optype_i   => optype_i,
    start_i    => start_i,
    finished_o => finished_o,
    result_o   => result_o,
    sign_o     => sign_o,
    overflow_o => overflow_o,
    error_o    => error_o
  );

  -- Generate the clock signal (100MHz)
  p_clk_gen : process
  begin
    clk_i <= '0';
    wait for 5 ns;
    clk_i <= '1';
    wait for 5 ns;
  end process;

  -- Stimulate the design with test inputs
  p_test : process
  begin

    --reset sequence
    reset_i <= '1';
    wait for 25 ns;
    reset_i <= '0';
    wait for 20 ns;

    
    for i in 0 to 4095 loop
      op1_i <= std_logic_vector(to_unsigned(i, 12));
      for j in 0 to 4095 loop
        op2_i <= std_logic_vector(to_unsigned(j, 12));

        --addition test
        optype_i <= "0000";
        start_i  <= '1';
        wait until finished_o = '1';
        wait for 10 ns;
        start_i <= '0';
        wait for 10 ns;
        assert result_o = std_logic_vector(to_unsigned(i + j, 16)) report "Addition failed" severity error;

        --exor test
        optype_i <= "1011";
        start_i  <= '1';
        wait until finished_o = '1';
        wait for 10 ns;
        start_i <= '0';
        wait for 10 ns;
        assert result_o = std_logic_vector(to_unsigned(i, 16)xor to_unsigned(j,16)) report "XOR failed" severity error;

        --not test
        optype_i <= "1000";
        start_i  <= '1';
        wait until finished_o = '1';
        wait for 10 ns;
        start_i <= '0';
        wait for 10 ns;
        assert result_o = std_logic_vector(not(to_unsigned(i, 16))) report "NOT failed" severity error;
      end loop; --j
    end loop; --i

    --square test until overflow
    for i in 1 to 255 loop
      op1_i    <= std_logic_vector(to_unsigned(i, 12));
      op2_i    <= std_logic_vector(to_unsigned(0, 12));
      optype_i <= "0101";
      start_i  <= '1';
      wait for 10 ns;
      start_i <= '0';
      wait until finished_o = '1';
      wait for 10 ns;
      assert result_o = std_logic_vector(to_unsigned(i * i, 16)) report "Square failed" severity error;
    end loop; --i

    -- square test with overflow
    op1_i    <= "000100000000";
    op2_i    <= "000000000000";
    optype_i <= "0101";
    start_i  <= '1';
    wait for 10 ns;
    start_i <= '0';
    wait until finished_o = '1';
    wait for 10 ns;
    assert overflow_o = '1' report "Overflow failed" severity error;

    --non implemented type test
    optype_i <= "0001";
    start_i <= '1';
    wait until finished_o = '1';
    wait for 10 ns;
    start_i <= '0';
    if error_o = '0' then
      assert false report "Error not detected" severity error;
    end if;
    wait for 10 ns;

    optype_i <= "0010";
    start_i <= '1';
    wait until finished_o = '1';
    wait for 10 ns;
    start_i <= '0';
    if error_o = '0' then
      assert false report "Error not detected" severity error;
    end if;
    wait for 10 ns;

    optype_i <= "0011";
    start_i <= '1';
    wait until finished_o = '1';
    wait for 10 ns;
    start_i <= '0';
    if error_o = '0' then
      assert false report "Error not detected" severity error;
    end if;
    wait for 10 ns;

    optype_i <= "0100";
    start_i <= '1';
    wait until finished_o = '1';
    wait for 10 ns;
    start_i <= '0';
    if error_o = '0' then
      assert false report "Error not detected" severity error;
    end if;
    wait for 10 ns;
    
    optype_i <= "0110";
    start_i <= '1';
    wait until finished_o = '1';
    wait for 10 ns;
    start_i <= '0';
    if error_o = '0' then
      assert false report "Error not detected" severity error;
    end if;
    wait for 10 ns;
    
    optype_i <= "0111";
    start_i <= '1';
    wait until finished_o = '1';
    wait for 10 ns;
    start_i <= '0';
    if error_o = '0' then
      assert false report "Error not detected" severity error;
    end if;
    wait for 10 ns;
    
    optype_i <= "1001";
    start_i <= '1';
    wait until finished_o = '1';
    wait for 10 ns;
    start_i <= '0';
    if error_o = '0' then
      assert false report "Error not detected" severity error;
    end if;
    wait for 10 ns;
    
    optype_i <= "1010";
    start_i <= '1';
    wait until finished_o = '1';
    wait for 10 ns;
    start_i <= '0';
    if error_o = '0' then
      assert false report "Error not detected" severity error;
    end if;
    wait for 10 ns;
    
    optype_i <= "1100";
    start_i <= '1';
    wait until finished_o = '1';
    wait for 10 ns;
    start_i <= '0';
    if error_o = '0' then
      assert false report "Error not detected" severity error;
    end if;
    wait for 10 ns;

    optype_i <= "1101";
    start_i <= '1';
    wait until finished_o = '1';
    wait for 10 ns;
    start_i <= '0';
    if error_o = '0' then
      assert false report "Error not detected" severity error;
    end if;
    wait for 10 ns;

    optype_i <= "1110";
    start_i <= '1';
    wait until finished_o = '1';
    wait for 10 ns;
    start_i <= '0';
    if error_o = '0' then
      assert false report "Error not detected" severity error;
    end if;
    wait for 10 ns;

    optype_i <= "1111";
    start_i <= '1';
    wait until finished_o = '1';
    wait for 10 ns;
    start_i <= '0';
    if error_o = '0' then
      assert false report "Error not detected" severity error;
    end if;
    wait for 10 ns;
    
    --visually pleasing test sequence

    --add test
    op1_i    <= "000000001101";
    op2_i    <= "000000000010";
    optype_i <= "0000";
    start_i  <= '1';
    wait for 10 ns;
    start_i <= '0';
    wait for 20 ns;

    --square test;
    op1_i    <= "000000000010";
    op2_i    <= "000000000000";
    optype_i <= "0101";
    start_i  <= '1';
    wait for 10 ns;
    start_i <= '0';
    wait until finished_o = '1';
    wait for 20 ns;
    op1_i    <= "000000001000";
    op2_i    <= "000000000001";
    optype_i <= "0101";
    start_i  <= '1';
    wait for 10 ns;
    start_i <= '0';
    wait until finished_o = '1';
    wait for 20 ns;

    --not test
    op1_i    <= "000000101010";
    op2_i    <= "000000000000";
    optype_i <= "1000";
    start_i  <= '1';
    wait for 10 ns;
    start_i <= '0';
    wait for 20 ns;

    --exor test
    op1_i    <= "000000010101";
    op2_i    <= "000000010011";
    optype_i <= "1011";
    start_i  <= '1';
    wait for 10 ns;
    start_i <= '0';
    wait for 20 ns;

    --notimplemented test
    op1_i    <= "000000010101";
    op2_i    <= "000000010011";
    optype_i <= "1001";
    start_i  <= '1';
    wait for 10 ns;
    start_i <= '0';
    wait for 20 ns;

    --testbench runs for more than 20 minutes!
    assert false report "Testbench finished" severity failure;
  end process;

end sim;