library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity can_phy is
    Port ( tx : in  STD_LOGIC;
           tx_en : in  STD_LOGIC;
           rx : out  STD_LOGIC;
	   can_collision : out STD_LOGIC; --detect detect collisions
           can_l : inout  STD_LOGIC;
           can_h : inout  STD_LOGIC);
end can_phy;

architecture RTL of can_phy is
       signal rx_out : std_logic; --create rx_out as buffer
begin
	rx <= rx_out;
	--driving the can bus when en is enabled
	can_l <= tx when (tx_en = '1') else 'Z';
	can_h <= not tx when (tx_en = '1') else 'Z';
	
	-- alway assign rx to can_h
	rx_out <= '1' when can_h = '1' and can_l ='0' else '0';
	
	--We can only detect when we send a 1 but the bus remains low
	can_collision <= '1' when tx ='1' and tx_en = '1' and not rx_out ='0' else '0';
end RTL;
