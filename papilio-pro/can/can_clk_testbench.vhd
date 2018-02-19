LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY can_clk_testbench IS
END can_clk_testbench;

ARCHITECTURE behavior OF can_clk_testbench IS 

  -- Component Declaration
  COMPONENT can_clk
  PORT(
        clk_in : IN std_logic;
        clk_div : IN std_logic;
        sync : in std_logic;
        sample_clk : out std_logic
        );
  END COMPONENT;

  --Inputs
          signal clk_in : std_logic := '0';
          signal clk_div : std_logic := '0';
          signal sync: std_logic := '0';

          --Outputs
          signal sample_clk : std_logic;

          --Logic components
          constant clk_period : time := 10 ns;
  BEGIN

  -- Component Instantiation
          uut: can_clk PORT MAP(
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
   
  --  Test Bench Statements
  tb : PROCESS
  BEGIN
    wait for 100 ns; -- wait until global set/reset completes
    -- Add user defined stimulus here

    --wait; -- will wait forever
     END PROCESS tb;
--  End Test Bench 
END;
