library ieee;
use ieee.std_logic_1164.all;

entity can is
    port (
        clk : in std_logic;
        rst : in std_logic;

	-- phy signals
        phy_tx : out std_logic;
	phy_tx_en : out std_logic;
	phy_rx: in std_logic;
	phy_can_h: out std_logic; -- can be Z
	phy_can_l: out std_logic -- can be Z
    );
end can;

architecture behavior of can is

   signal can_phy_can_collision : std_logic;

   --These signals can are to be used between the FPGA phy and tx
   --but in a real implementation.. they are external
   signal buf_can_tx : std_logic;
   signal buf_can_tx_en : std_logic;
   signal buf_can_rx : std_logic;
  

  -- Signals
  signal can_bus_value: std_logic := '0';        --The current value on the can bus
  signal can_clk_sample_set_clk: std_logic := '0';   --Sync Signal to set a value on the can bus
  signal can_clk_sample_check_clk: std_logic := '0'; --Sync Signal to check a value on the can bus
  signal can_clk_sample_get_clk: std_logic := '0';   --Sync Signal to read the value of a signal

  signal can_tx_id   :   std_logic_vector (31 downto 0) := (others => '0'); -- 32 bit can_id + eff/rtr/err flags 
  signal can_tx_dlc  :   std_logic_vector (3 downto 0) := (others => '0');
  signal can_tx_data    :   std_logic_vector (63 downto 0) := (others => '0');
  signal can_tx_valid   :   std_logic := '0';    --Sync signal to read the values and start pushing them on the bus
  signal can_tx_status      :  std_logic_vector (31 downto 0):= (others => '0'); --transmit status
begin

  -- can phy
  can_phy: entity work.can_phy port map (
          tx => buf_can_tx, --- needs fixing... tx is 
          tx_en => buf_can_tx_en,
          rx => buf_can_rx,
          can_collision  => can_phy_can_collision,
          can_l => phy_can_l,
          can_h => phy_can_h
        );
   
  -- can clock generation 
  can_clk: entity work.can_clk port map(
    clk => clk ,
    rst => rst,
    can_bus_value => can_bus_value ,
    can_sample_set_clk => can_clk_sample_set_clk ,
    can_sample_check_clk => can_clk_sample_check_clk ,
    can_sample_get_clk => can_clk_sample_get_clk 
  );

  -- can sending of messages
  can_tx: entity work.can_tx port map(
        clk => clk, 
        can_id  => can_tx_id,
        can_dlc => can_tx_dlc,
        can_data   => can_tx_data,
        can_valid  => can_tx_valid,
        status     => can_tx_status,
        can_signal_set => can_clk_sample_set_clk,
        can_phy_tx  => can_phy_tx,
        can_phy_tx_en  => can_phy_tx_en,
        can_phy_rx     => can_phy_rx
    );

end;
