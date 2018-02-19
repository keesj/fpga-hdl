library ieee;
use ieee.std_logic_1164.all;

entity can_tx is
    port ( clk      : in  std_logic;            
            can_id   : in  std_logic_vector (31 downto 0);-- 32 bit can_id + eff/rtr/err flags 
		    can_dlc  : in std_logic_vector (3 downto 0);
		    can_data : in std_logic_vector (63 downto 0);
		    can_valid: in  std_logic;
			status   : out  std_logic_vector (32 downto 0));
end can_tx;

architecture rtl of can_tx is
    -- sff(11 bit) and eff (29 bit)  is set in the msb  of can_id
    signal can_eff : std_logic;
    signal can_rtr : std_logic;
    signal can_packet : std_logic_vector (16 downto 0);
begin
	can_eff <= can_id(31);
	can_rtr <= can_id(30);
	
	count: process(clk,can_valid)
	begin
		if rising_edge(clk) then
			if can_valid = '1' then
			  can_packet <= '0' & can_id(11 downto 0) & can_rtr & '0' & '0' ;
			end if;
		end if;
	end process;
end rtl;

