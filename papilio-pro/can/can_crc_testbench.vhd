library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity can_crc_testbench is
end can_crc_testbench;

architecture behavior of can_crc_testbench is 

  -- component declaration
  component can_crc
   port ( clk : in  std_logic;
          din : in  std_logic;
          ce : in  std_logic;
          rst : in std_logic;
          crc : out  std_logic_vector(14 downto 0)
    );
  end component;
  
  signal data : std_logic_vector(7 downto 0) := "01010101";
  signal clk : std_logic;
  signal din: std_logic;
  signal ce: std_logic;
  signal rst : std_logic;
  signal crc: std_logic_vector(14 downto 0);
  constant clk_period : time := 10 ns;

 begin

     uut: can_crc port map(
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
  
  tb : process is
    variable l : line;
  begin
    wait for 10 ns;

    wait until falling_edge(clk);
    rst <= '1';   
    wait until rising_edge(clk);
    wait until falling_edge(clk);
    rst <= '0';

    for i in 0 to 7 loop
      din <= data(6);
      ce <='1';
      wait until rising_edge(clk);
      wait until falling_edge(clk);
      ce <='0';
      report "DATA " &  std_logic'image(din);
      data <= data(6 downto 0) & '0';
    end loop;
    report "DONE";
    wait;
  end process tb;
end;
