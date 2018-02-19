library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity can_clk is
    port ( clk_in : in  std_logic;
           clk_div : in  std_logic;
           sync : in  std_logic;
           sample_clk : out  std_logic);
end can_clk;

architecture rtl of can_clk is
	signal counter : signed (7 downto 0) := (others => '0');		
begin
	-- Input clock is 100 mhz
	-- Can bit time if 500.000 hence we want 10 faster
	-- 500 khz
	count: process(clk_in,sync)
	begin
		if rising_edge(clk_in) then
			counter <= counter +1;	
			sample_clk <= counter(3);
		end if;
		if rising_edge(sync) then
			counter <= (others => '0');
		end if;
	end process;
	
end rtl;

