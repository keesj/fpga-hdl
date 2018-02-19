LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY can_crc_testbench IS
END can_crc_testbench;

ARCHITECTURE behavior OF can_crc_testbench IS 

  -- Component Declaration
  COMPONENT can_crc
   Port ( clk : in  STD_LOGIC;
			  din : in  STD_LOGIC;
           ce : in  STD_LOGIC;
			  rst : in STD_LOGIC;
           crc : out  STD_LOGIC_VECTOR(14 downto 0)
    );
  END COMPONENT;
  
  signal clk : STD_LOGIC;
  signal din: STD_LOGIC;
  signal ce: STD_LOGIC;
  signal rst : STD_LOGIC;
  signal crc: STD_LOGIC_VECTOR(14 downto 0);
  constant clk_period : time := 10 ns;
  constant wait_time : time := 30ns;
 BEGIN

     uut: can_crc PORT MAP(
			clk => clk,
			din => din,
			ce => ce,
			rst => rst,
			crc => crc
          );

   clk_process :process
   begin
        clk <= '0';
        wait for clk_period/2;  --for 0.5 ns signal is '0'.
        clk <= '1';
        wait for clk_period/2;  --for next 0.5 ns signal is '1'.
   end process;
  
  tb : PROCESS
  BEGIN
    wait for 10 ns;
	 rst <= '1';
	 wait for wait_time;
	 rst <= '0';
	 report "CRC value ";
	 
	 din <= '1';
	 ce <='1';
	 wait for wait_time;
	 ce <= '0';
	 
	 wait;
  END PROCESS tb;
END;
