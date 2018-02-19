library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity can_tx is
    Port ( clk      : in  STD_LOGIC;            
           can_id   : in  STD_LOGIC_VECTOR (31 downto 0);-- 32 bit CAN_ID + EFF/RTR/ERR flags 
		   can_dlc  : in STD_LOGIC_VECTOR (3 downto 0);
		   can_data : in STD_LOGIC_VECTOR (63 downto 0);
		   can_valid: in  STD_LOGIC;
           status   : out  STD_LOGIC_VECTOR (32 downto 0));
end can_tx;

architecture Behavioral of can_tx is
    -- SFF(11 bit) and EFF (29 bit)  is set in the MSB  of can_id
    signal can_eff : STD_LOGIC;
    signal can_rtr : STD_LOGIC;
    signal can_packet : STD_LOGIC_VECTOR (16 downto 0);
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
end Behavioral;

