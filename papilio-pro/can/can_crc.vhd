library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


-- based on 
-- http://srecord.sourceforge.net/crc16-ccitt.html
-- and https://www.can-cia.org/can-knowledge/can/crc/
entity can_crc is
    Port ( clk : in  STD_LOGIC;
			  din : in  STD_LOGIC;
           ce : in  STD_LOGIC;
			  rst : in STD_LOGIC;
           crc : out  STD_LOGIC_VECTOR(14 downto 0)
    );
end can_crc;

architecture RTL of can_crc is
	signal crc_val : STD_LOGIC_VECTOR (14 downto 0);
begin
	crc <= crc_val;
	count: process(clk,rst,ce)
	begin
		if rst = '1' then
 			crc_val <= (others => '1');		
		elsif rising_edge(ce) then
			if rising_edge(clk) then
       		-- x15 + x14 + x10 + x8 + x7 +x4 +x3 + 1 
				crc_val(0) <= crc_val(14) xor din;
				crc_val(1) <= crc_val(0);
				crc_val(2) <= crc_val(1);
				crc_val(3) <= crc_val(2) xor (din xor crc_val(14));
				crc_val(4) <= crc_val(3) xor (din xor crc_val(14));
				crc_val(5) <= crc_val(4);
				crc_val(6) <= crc_val(5);
				crc_val(7) <= crc_val(6) xor (din xor crc_val(14));
				crc_val(8) <= crc_val(7) xor (din xor crc_val(14));
				crc_val(9) <= crc_val(8);
				crc_val(10)<= crc_val(9) xor (din xor crc_val(14));
				crc_val(11)<= crc_val(10);
				crc_val(12)<= crc_val(11);
				crc_val(13)<= crc_val(12);
				crc_val(14)<= crc_val(13) xor (din xor crc_val(14));
			end if;
		end if;
	end process;
end RTL;

