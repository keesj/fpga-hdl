library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

entity can_wb is
   port ( wishbone_in  : in    std_logic_vector (100 downto 0); 
          wishbone_out : out   std_logic_vector (100 downto 0);
 
          --non wishbone connections
          tx    : out std_logic;
          tx_en : out std_logic;
          rx    : in std_logic
        );
end can_wb;

architecture behavior of can_wb is

  -- exelent documentation here
  -- http://zipcpu.com/zipcpu/2017/05/29/simple-wishbone.html
  --WB
  signal  wb_clk_i:    std_logic;                     -- Wishbone clock
  signal  wb_rst_i:    std_logic;                     -- Wishbone reset (synchronous)
  signal  wb_dat_i:    std_logic_vector(31 downto 0); -- Wishbone data input  (32 bits)
  signal  wb_adr_i:    std_logic_vector(26 downto 2); -- Wishbone address input  (32 bits)
  signal  wb_we_i:     std_logic;                     -- Wishbone write enable signal
  signal  wb_cyc_i:    std_logic;                     -- Wishbone cycle signal
  signal  wb_stb_i:    std_logic;                     -- Wishbone strobe signal  
    
  signal  wb_dat_o:    std_logic_vector(31 downto 0); -- Wishbone data output (32 bits)
  signal  wb_ack_o:    std_logic;                     -- Wishbone acknowledge out signal
  signal  wb_inta_o:   std_logic;

  signal version                    : std_logic_vector( 31 downto 0)  := x"13371337";
  signal config_settings            : std_logic_vector( 31 downto 0)  := (others => '0');

  signal can0_can_sample_rate       : std_logic_vector (31 downto 0) := (others => '0'); --
  signal can0_rst                   : std_logic;
  signal can0_can_tx_id             : std_logic_vector (31 downto 0) := (others => '0'); -- 32 bit can_id + eff/rtr/err flags 
  signal can0_can_tx_dlc            : std_logic_vector (3 downto 0) := (others => '0');  -- data lenght
  signal can0_can_tx_data           : std_logic_vector (63 downto 0) := (others => '0'); -- data
  signal can0_can_tx_valid          : std_logic := '0';    --Sync signal to read the values and start pushing them on the bus
  signal can0_can_rx_id             : std_logic_vector (31 downto 0) := (others => '0'); -- 32 bit can_id + eff/rtr/err flags 
  signal can0_can_rx_dlc            : std_logic_vector (3 downto 0) := (others => '0');  -- data lenght
  signal can0_can_rx_data           : std_logic_vector (63 downto 0) := (others => '0'); -- data
  signal can0_can_rx_valid          : std_logic := '0';    --Sync that the data is valid
  signal can0_can_rx_drr            : std_logic := '0';     --rx data read ready (the fields can be invaludated and a new frame can be accepter)
  signal can0_can_status            : std_logic_vector (31 downto 0) := (others => '0');
  signal can0_can_rx_id_filter      : std_logic_vector (31 downto 0) := (others => '0');
  signal can0_can_rx_id_filter_mask : std_logic_vector (31 downto 0) := (others => '0');
  signal can0_phy_tx                : std_logic;
  signal can0_phy_tx_en             : std_logic;
  signal can0_phy_rx                : std_logic;
 
  COMPONENT can
    port (
        -- Standard signals
        clk : in std_logic;
        rst : in std_logic;
        
        can_sample_rate : in std_logic_vector(31 downto 0) := (0=>'1' , others => '0');
        
        --can TX related
        can_tx_id    : in std_logic_vector (31 downto 0) := (others => '0'); -- 32 bit can_id + eff/rtr/err flags 
        can_tx_dlc   : in std_logic_vector (3 downto 0) := (others => '0');  -- data lenght
        can_tx_data  : in std_logic_vector (63 downto 0) := (others => '0'); -- data
        can_tx_valid : in std_logic := '0';    --Sync signal to read the values and start pushing them on the bus

        --can RX related
        can_rx_id    : out std_logic_vector (31 downto 0) := (others => '0'); -- 32 bit can_id + eff/rtr/err flags 
        can_rx_dlc   : out std_logic_vector (3 downto 0) := (others => '0');  -- data lenght
        can_rx_data  : out std_logic_vector (63 downto 0) := (others => '0'); -- data
        can_rx_valid : out std_logic := '0';    --Sync that the data is valid
        can_rx_drr   : in std_logic := '0';     --rx data read ready (the fields can be invaludated and a new frame can be accepter)

        can_status   : out std_logic_vector (31 downto 0) := (others => '0');

        -- can_rx_filter
        can_rx_id_filter       : in  std_logic_vector (31 downto 0) := (others => '0');
        can_rx_id_filter_mask  : in  std_logic_vector (31 downto 0) := (others => '0');

        -- phy signals
        phy_tx    : out std_logic;
        phy_tx_en : out std_logic;
        phy_rx    : in std_logic
    );
  END COMPONENT;
begin

  -- Unpack the wishbone array into signals so the modules code is not confusing. - Don't touch.
  wb_clk_i <= wishbone_in(61);           -- clock
  wb_rst_i <= wishbone_in(60);           -- reset signal
  wb_dat_i <= wishbone_in(59 downto 28); -- the date the master wishes to write
  wb_adr_i <= wishbone_in(27 downto 3);  -- contains the address of the request
  wb_we_i  <= wishbone_in(2);             -- true for any write requests
  wb_cyc_i <= wishbone_in(1);            -- is true any time a wishbone transaction is taking place
  wb_stb_i <= wishbone_in(0);            -- is true for any bus transaction request.

  wishbone_out(33 downto 2) <= wb_dat_o;
  wishbone_out(1)           <= wb_ack_o;
  wishbone_out(0)           <= wb_inta_o;
  -- End unpacking Wishbone signals

  can0: can port MAP(
        clk => wb_clk_i,
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
        phy_tx  => tx,
        phy_tx_en => tx_en,
        phy_rx    => rx
);

  --map registers
  -- 00 RO version h"13371337'
  -- 01 RO status bit 0 denotes a transmit request. bit 1 a read to receive singal
  -- 02 RW RESERVED CONF SETTINGS (loopback,selftest )

  -- 03 RW CONF sample rate
  -- 04 RW CONF RX id filter
  -- 05 RW CONF RX id filter mask

  -- 06 RW TX tx_id (11 msb are id) and lsb is request response
  -- 07 RW TX the 4 lsb bytes are the data length (code)
  -- 08 RW TX bits 31 to 0 of the data 
  -- 09 RW bits 63 to 32 of the data 
  -- 0A WO TX_VALID

  -- 0B RO RX tx _id (11 msb are id) and lsb is request response
  -- 0C RO RX LCD the 4 lsb bytes are the data length (code)
  -- 0d RO RX RX_DAT0 
  -- 0e RO RX RX_DAT1
  -- 0f WO TX_DATA_READ_READY (the data has been read)

  --register8_in <= can0_can_status;       -- get status (rx/tx)
  --register9_in <= x"deadbeef";       -- get status (rx/tx)

  can0_rst <= wishbone_in(60);

  --wb 
  wb_ack_o <= '1' when wb_cyc_i='1' and wb_stb_i='1' else '0';

  -- wishbone read requests
  process(can0_can_status, wb_adr_i)
  begin
    case wb_adr_i(9 downto 2) is
      when x"00" => wb_dat_o <= version;
      when x"01" => -- skip wb_dat_o <= can0_can_status ;
      when x"02" => wb_dat_o <= config_settings;
      when x"03" => wb_dat_o <= can0_can_sample_rate;
      when x"04" => wb_dat_o <= can0_can_rx_id_filter;
      when x"05" => wb_dat_o <= can0_can_rx_id_filter_mask;
      when x"06" => wb_dat_o <= can0_can_tx_id;                -- not very usefull
      when x"07" => wb_dat_o <= 28x"0" & can0_can_tx_dlc;               -- not very usefull
      when x"08" => wb_dat_o <= can0_can_tx_data(31 downto 0); -- not very usefull
      when x"09" => wb_dat_o <= can0_can_tx_data(63 downto 32);-- not very usefull
      when x"0a" => wb_dat_o <= 31x"0" & can0_can_tx_valid;             -- not very usefull
      when x"0b" => wb_dat_o <= can0_can_rx_id;
      when x"0c" => wb_dat_o <= 28x"0" & can0_can_rx_dlc;
      when x"0d" => wb_dat_o <= can0_can_rx_data(31 downto 0);
      when x"0e" => wb_dat_o <= can0_can_rx_data(63 downto 32);
      when x"0f" => -- ksip wb_dat_o <= allzero(31 downto 1) & can0_can_rx_drr;
      when others => wb_dat_o <= (others => 'X'); -- Return undefined for all other addresses
    end case;
  end process;

  -- wishbone write requests
  process(wb_clk_i)
  begin
    if rising_edge(wb_clk_i) then  -- Synchronous to the rising edge of the clock
      if wb_cyc_i='1' and wb_stb_i='1' and wb_we_i='1' then
        case wb_adr_i(9 downto 2) is
          -- configuration fields
          when x"00" =>  --ignore version
          when x"01" => can0_can_status <=  wb_dat_i;
          when x"02" => config_settings <=  wb_dat_i;
          when x"03" => can0_can_sample_rate <=  wb_dat_i;
          when x"04" => can0_can_rx_id_filter <=  wb_dat_i;
          when x"05" => can0_can_rx_id_filter_mask <=  wb_dat_i;
          when x"06" => can0_can_tx_id <=  wb_dat_i;
          when x"07" => can0_can_tx_dlc <=  wb_dat_i;
          when x"08" => can0_can_tx_data(31 downto 0) <=  wb_dat_i;
          when x"09" => can0_can_tx_data(63 downto 32) <=  wb_dat_i;
          when x"0a" => can0_can_tx_valid <= wb_dat_i(0);
          when x"0b" =>  -- skip can0_can_rx_id <=  wb_dat_i;
          when x"0c" =>  -- skip can0_can_rx_dlc <=  wb_dat_i;
          when x"0d" =>  -- skip  can0_can_rx_data(31 downto 0) <=  wb_dat_i;
          when x"0e" =>  -- skip can0_can_rx_data(63 downto 32) <=  wb_dat_i;
          when x"0f" => can0_can_rx_drr <=  wb_dat_i(0);
          when others => 
        end case;
      end if;
    end if;
  end process;
end behavior;