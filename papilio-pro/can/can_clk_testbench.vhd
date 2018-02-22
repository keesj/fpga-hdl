library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity can_clk_testbench is
end can_clk_testbench;

architecture behavior of can_clk_testbench is 

  -- Component declaration
  component can_clk
    port ( clk : in std_logic;
           can_bus_value : in  std_logic;         -- The current value of the but. used to detect edges and adapt the clock
           can_sample_set_clk : out  std_logic;   -- Signal an outgoing sample must be set (firest quanta)
           can_sample_check_clk : out  std_logic; -- Signal the value of a signal can be checked to detect collision
           can_sample_get_clk : out  std_logic);  -- Singal that the incommint sample can be read
  end component;

  -- Inputs
  signal clk : std_logic := '0';
  signal can_bus_value: std_logic := '0';

   -- Outputs
  signal can_sample_set_clk: std_logic := '0';
  signal can_sample_check_clk: std_logic := '0';
  signal can_sample_get_clk: std_logic := '0';

   -- Logic components
  constant clk_period : time := 10 ns;
  begin

  -- Component instantiation
  uut: can_clk port map(
    clk => clk ,
    can_bus_value => can_bus_value ,
    can_sample_set_clk => can_sample_set_clk ,
    can_sample_check_clk => can_sample_check_clk ,
    can_sample_get_clk => can_sample_get_clk 
  );

  clk_process :process
  begin
    clk <= '0';
    wait for clk_period/2;  --for 0.5 ns signal is '0'.
    clk <= '1';
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
