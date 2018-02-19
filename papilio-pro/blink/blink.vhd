library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity blink is
    port ( clk : in  STD_LOGIC;
           led : out  STD_LOGIC;
	   sig : out  std_logic_vector(15 downto 0)
	  );
end blink;

architecture Behavioral of blink is
	signal counter : std_logic_vector(25 downto 0) := (others => '0');
	alias fastCounter: std_logic_vector(15 downto 0) is counter(24 downto 9);
begin
        clk_proc: process(clk)
        begin
                if rising_edge(clk) then
                        counter <= counter + '1';
                        led <= counter(25);
			sig <= fastCounter;
                end if;
        end process;
end Behavioral;

