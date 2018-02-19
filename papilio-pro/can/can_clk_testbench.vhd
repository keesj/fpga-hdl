library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity can_clk_testbench is
end can_clk_testbench;

architecture behavior of can_clk_testbench is 

  -- Component declaration
  component can_clk
  port( clk_in : in std_logic;
        clk_div : in std_logic;
        sync : in std_logic;
        sample_clk : out std_logic
        );
  end component;

  -- Inputs
  signal clk_in : std_logic := '0';
  signal clk_div : std_logic := '0';
  signal sync: std_logic := '0';

   -- Outputs
  signal sample_clk : std_logic;

   -- Logic components
  constant clk_period : time := 10 ns;
  begin

  -- Component instantiation
  uut: can_clk port map(
    clk_in => clk_in ,
    clk_div => clk_div,
    sync => sync,
    sample_clk => sample_clk
  );

  clk_process :process
  begin
    clk_in <= '0';
    wait for clk_period/2;  --for 0.5 ns signal is '0'.
    clk_in <= '1';
    wait for clk_period/2;  --for next 0.5 ns signal is '1'.
  end process;
   
  -- Test bench statements
  tb : process
  begin
    wait for 100 ns; -- wait until global set/reset completes
    -- add user defined stimulus here

    --wait; -- will wait forever
  end process tb;
   --  end test bench 
end;
