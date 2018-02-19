library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity can_clk is
    Port ( clk_in : in  STD_LOGIC;
           clk_div : in  STD_LOGIC;
           sync : in  STD_LOGIC;
           sample_clk : out  STD_LOGIC);
end can_clk;

architecture RTL of can_clk is
	signal counter : SIGNED (7 downto 0) := (others => '0');		
begin
	--input clock is 100 Mhz
	--can bit time if 500.000 hence we want 10 faster
	--500 Khz
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
	
end RTL;

