library ieee;
use ieee.std_logic_1164.all;

entity can is
    port (
        -- Standard signals
        clk : in std_logic;
        rst : in std_logic;
        
        --can TX related
        can_tx_id    : in std_logic_vector (31 downto 0) := (others => '0'); -- 32 bit can_id + eff/rtr/err flags 
        can_tx_dlc   : in std_logic_vector (3 downto 0) := (others => '0');  -- data lenght
        can_tx_data  : in std_logic_vector (63 downto 0) := (others => '0'); -- data
        can_tx_valid : in std_logic := '0';    --Sync signal to read the values and start pushing them on the bus

        -- phy signals
        phy_tx    : out std_logic;
        phy_tx_en : out std_logic;
        phy_rx    : in std_logic
    );
end can;

architecture behavior of can is

  -- Signals
  signal can_clk_sync: std_logic := '0';            --The current value on the can bus
  signal can_clk_sample_set_clk: std_logic := '0';   --Sync Signal to set a value on the can bus
  signal can_clk_sample_check_clk: std_logic := '0'; --Sync Signal to check a value on the can bus
  signal can_clk_sample_get_clk: std_logic := '0';   --Sync Signal to read the value of a signal

  signal can_tx_status : std_logic_vector (31 downto 0):= (others => '0'); --transmit status
begin

  -- can clock generation 
  can_clk: entity work.can_clk port map(
    clk => clk ,
    rst => rst,
    can_clk_sync => can_clk_sync ,
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
        can_phy_tx  => phy_tx,
        can_phy_tx_en  => phy_tx_en,
        can_phy_rx     => phy_rx
    );
end;
