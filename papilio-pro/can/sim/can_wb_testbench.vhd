library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity can_wb_testbench is
end can_wb_testbench;

architecture behavior of can_wb_testbench is
    signal test_running :  std_logic := '1';

    signal clk :  std_logic;

    signal can0_can_config : std_logic_vector (31 downto 0) :=  (0 => '1' , others => '0');
    signal can0_can_sample_rate :  std_logic_vector (31 downto 0) := (others => '0'); --
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

    signal wishbone_in  : std_logic_vector (100 downto 0); 
    signal wishbone_out : std_logic_vector (100 downto 0);

    alias wb_clk_i is wishbone_in(61);           -- clock
    alias wb_rst_i is wishbone_in(60);           -- reset signal
    alias wb_dat_i is wishbone_in(59 downto 28); -- the date the master wishes to write
    alias wb_adr_i is wishbone_in(27 downto 3);  -- contains the address of the request
    alias wb_we_i  is wishbone_in(2);             -- true for any write requests
    alias wb_cyc_i is wishbone_in(1);            -- is true any time a wishbone transaction is taking place
    alias wb_stb_i is wishbone_in(0);            -- is true for any bus transaction request.
    alias wb_dat_o is wishbone_out(33 downto 2);
    alias wb_ack_o is wishbone_out(1);
    alias wb_inta_o is wishbone_out(0);

begin

        -- Unpack the wishbone array into signals so the modules code is not confusing. - Don't touch.

    -- End unpacking Wishbone signals

    uut0: entity work.can_wb port map(
        wishbone_in => wishbone_in,
        wishbone_out => wishbone_out,
        tx  => can0_phy_tx,
        tx_en => can0_phy_tx_en,
        rx    => can0_phy_rx
    );

    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
        if test_running = '0' then
          wait;
        end if;
    end process;

    can0_test : process
    begin
        wait for clk_period * 40;

        --set sample rate
        can0_can_sample_rate <=  std_logic_vector(to_unsigned(1,32));

        wait until rising_edge(clk);
        wait until falling_edge(clk);

        for i in 0 to 10 loop
            --prepare to recieve some data
            can0_can_rx_drr <= '1';
            wait until rising_edge(clk);
            wait until falling_edge(clk);
            can0_can_rx_drr <= '0';

            wait until rising_edge(clk);
            wait until falling_edge(clk);


            can0_can_tx_id(31 downto 21) <= "11000001101";
            can0_can_tx_id(0) <= '0';
            can0_can_tx_dlc <= x"8";
            can0_can_tx_data <= x"ff01020304050607";

            can0_can_tx_valid <= '1'; 
            wait until rising_edge(clk);
            wait until falling_edge(clk);
            can0_can_tx_valid <= '0';

            wait until can0_can_status(0) ='0';
--            wait until can0_can_status(1) ='0';
            assert can0_can_rx_id = can0_can_tx_id report "CAN ID ERROR" severity failure;
            assert can0_can_status(2) = '0' report "CAN RX CRC ERROR" severity failure;

        end loop;
        
	
        report "DONE";
        test_running <= '0';
        wait;
        --set sample rate

    end process;
end;
