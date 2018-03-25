library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity can_testbench is
end can_testbench;

architecture behavior of can_testbench is
    signal clk :  std_logic;
    signal can0_can_sample_rate :  std_logic_vector (31 downto 0) := (others => '0'); --
    signal can0_rst :  std_logic;
    signal can0_can_tx_id    :  std_logic_vector (31 downto 0) := (others => '0'); -- 32 bit can_id + eff/rtr/err flags 
    signal can0_can_tx_dlc   :  std_logic_vector (3 downto 0) := (others => '0');  -- data lenght
    signal can0_can_tx_data  :  std_logic_vector (63 downto 0) := (others => '0'); -- data
    signal can0_can_tx_valid :  std_logic := '0';    --Sync signal to read the values and start pushing them on the bus
    signal can0_can_rx_id    :  std_logic_vector (31 downto 0) := (others => '0'); -- 32 bit can_id + eff/rtr/err flags 
    signal can0_can_rx_dlc   :  std_logic_vector (3 downto 0) := (others => '0');  -- data lenght
    signal can0_can_rx_data  :  std_logic_vector (63 downto 0) := (others => '0'); -- data
    signal can0_can_rx_valid :  std_logic := '0';    --Sync that the data is valid
    signal can0_can_rx_drr   :  std_logic := '0';     --rx data read ready (the fields can be invaludated and a new frame can be accepter)
    signal can0_can_status   :  std_logic_vector (31 downto 0) := (others => '0');
    signal can0_can_rx_id_filter       :   std_logic_vector (31 downto 0) := (others => '0');
    signal can0_can_rx_id_filter_mask  :   std_logic_vector (31 downto 0) := (others => '0');
    signal can0_phy_tx    :  std_logic;
    signal can0_phy_tx_en :  std_logic;
    signal can0_phy_rx    :  std_logic;

    constant clk_period : time := 10 ns;
begin

    uut: entity work.can port map(
        clk => clk,
        rst => can0_rst,
        can_sample_rate=> can0_can_sample_rate,
        can_tx_id  => can0_can_tx_id,
        can_tx_dlc => can0_can_tx_dlc,
        can_tx_data => can0_can_tx_data,
        can_tx_valid => can0_can_tx_valid,
        can_rx_id  => can0_can_rx_id,
        can_rx_dlc => can0_can_rx_dlc,
        can_rx_data => can0_can_rx_data,
        can_rx_valid => can0_can_rx_valid,
        can_rx_drr => can0_can_rx_drr,
        can_status => can0_can_status,
        can_rx_id_filter => can0_can_rx_id_filter,
        can_rx_id_filter_mask => can0_can_rx_id_filter_mask,
        phy_tx  => can0_phy_rx,
        phy_tx_en => can0_phy_tx_en,
        phy_rx    => can0_phy_rx
    );

    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    can0_test : process
    begin
        --reset
        can0_rst <= '1';
        wait until rising_edge(clk);
        wait until falling_edge(clk);
        can0_rst <= '0';
        --set sample rate
        can0_can_sample_rate <=  std_logic_vector(to_unsigned(50,32));
        
        --set sample rate

    end process;
end;