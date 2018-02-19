library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity can_crc is
    Port ( clk : in  STD_LOGIC;
           bit : in  STD_LOGIC;
           rst : in  STD_LOGIC;
			  bit_set : in STD_LOGIC;
           crc : out  STD_LOGIC_VECTOR (14 downto 0));
end can_crc;

architecture Behavioral of can_crc is
	signal polynominal : STD_LOGIC_VECTOR(14 downto 0);
begin
	--  x15 + x14 + x10 + x8 + x7 +x4 +x3 + x0
   polynominal := '1100010110011001';


end Behavioral;

