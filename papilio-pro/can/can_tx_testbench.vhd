library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity can_tx_testbench is
end can_tx_testbench;

architecture behavior of can_tx_testbench is

    component can_tx
    port (  clk         : in  std_logic;            
	
            can_id      : in  std_logic_vector (31 downto 0);-- 32 bit can_id + eff/rtr/err flags 
		    can_dlc     : in  std_logic_vector (3 downto 0);
		    can_data    : in  std_logic_vector (63 downto 0);
		    can_valid   : in  std_logic;
			can_start   : in  std_logic;
			status      : out std_logic_vector (32 downto 0);

			can_phy_tx     : out  std_logic;
			can_phy_tx_en  : out  std_logic;
			can_phy_rx     : in std_logic
    );
    end component;

    signal clk         :   std_logic;            
    signal can_id      :   std_logic_vector (31 downto 0);-- 32 bit can_id + eff/rtr/err flags 
    signal can_dlc     :   std_logic_vector (3 downto 0);
    signal can_data    :   std_logic_vector (63 downto 0);
    signal can_valid   :   std_logic;
    signal can_start   :   std_logic;
    signal status      :  std_logic_vector (32 downto 0);
    signal can_phy_tx     :   std_logic;
    signal can_phy_tx_en  :   std_logic;
    signal can_phy_rx     :  std_logic;

begin
    uut: can_tx port map(
        clk => clk, 
        can_id  => can_id,
        can_dlc => can_dlc,
        can_data   => can_data,
        can_valid  => can_valid,
        can_start  => can_start,
        status     => status,
        can_phy_tx  => can_phy_tx,
        can_phy_tx_en  => can_phy_tx_en,
        can_phy_rx     => can_phy_rx
    );
end;