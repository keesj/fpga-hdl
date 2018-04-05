library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

entity can_wb is
   port ( wishbone_in  : in    std_logic_vector (100 downto 0); 
          wishbone_out : out   std_logic_vector (100 downto 0);
 
          --Put your external connections here
          tx : out std_logic;
          tx_en : out std_logic;
          rx : in std_logic
        );
end can_wb;

architecture BEHAVIORAL of can_wb is

  --WB
  signal  wb_clk_i:    std_logic;                     -- Wishbone clock
  signal  wb_rst_i:    std_logic;                     -- Wishbone reset (synchronous)
  signal  wb_dat_i:    std_logic_vector(31 downto 0); -- Wishbone data input  (32 bits)
  signal  wb_adr_i:    std_logic_vector(26 downto 2); -- Wishbone address input  (32 bits)
  signal  wb_we_i:     std_logic;                     -- Wishbone write enable signal
  signal  wb_cyc_i:    std_logic;                     -- Wishbone cycle signal
  signal  wb_stb_i:    std_logic;                     -- Wishbone strobe signal  
    
  signal  wb_dat_o:    std_logic_vector(31 downto 0); -- Wishbone data output (32 bits)
  signal  wb_ack_o:    std_logic;                      -- Wishbone acknowledge out signal
  signal  wb_inta_o:   std_logic;

  signal can0_clk :  std_logic;
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
  signal can0_phy_tx                :  std_logic;
  signal can0_phy_tx_en             :  std_logic;
  signal can0_phy_rx                :  std_logic;
 
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
wb_clk_i <= wishbone_in(61);
wb_rst_i <= wishbone_in(60);
wb_dat_i <= wishbone_in(59 downto 28);
wb_adr_i <= wishbone_in(27 downto 3);
wb_we_i <= wishbone_in(2);
wb_cyc_i <= wishbone_in(1);
wb_stb_i <= wishbone_in(0); 

wishbone_out(33 downto 2) <= wb_dat_o;
wishbone_out(1) <= wb_ack_o;
wishbone_out(0) <= wb_inta_o;
-- End unpacking Wishbone signals

--Put your code here
--leds <= register0_out(3 downto 0);
--register1_in(3 downto 0) <= buttons;
can0: can port MAP(
        clk => can0_clk,
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
  -- 00 sample rate
  -- 01 id filter
  -- 02 id filter mask
  -- 03 rx_id (11 msb are id) and lsb is request response
  -- 04 the 4 lsb bytes are the data length (code)
  -- 05 bits 31 to 0 of the data 
  -- 06 bits 63 to 32 of the data 
  -- 07 bit 0 denotes a transmit request. bit 1 a read to receive singal
  --register8_in <= can0_can_status;       -- get status (rx/tx)
  --register9_in <= x"deadbeef";       -- get status (rx/tx)

  can0_clk <= wishbone_in(61);
  can0_rst <= wishbone_in(60);

  --wb 
  wb_ack_o <= '1' when wb_cyc_i='1' and wb_stb_i='1' else '0';

  process(can0_can_status, wb_adr_i)
  begin
    case wb_adr_i(9 downto 2) is
      when x"08" => wb_dat_o <= can0_can_status ;
      when x"09" => wb_dat_o <= x"deadbeef";  -- Output register1
      when others => wb_dat_o <= (others => 'X'); -- Return undefined for all other addresses
    end case;
  end process;

  process(wb_clk_i)
  begin
    if rising_edge(wb_clk_i) then  -- Synchronous to the rising edge of the clock
      if wb_cyc_i='1' and wb_stb_i='1' and wb_we_i='1' and wb_rst_i='0' then
        -- Yes, it's a write. See for which register based on address
        case wb_adr_i(9 downto 2) is
          when x"00" => can0_can_sample_rate <=  wb_dat_i;
          when x"01" => can0_can_rx_id_filter <=  wb_dat_i;
          when x"02" => can0_can_rx_id_filter_mask <=  wb_dat_i;
          when x"03" => can0_can_tx_id <= wb_dat_i;
          when x"04" => can0_can_tx_dlc <= wb_dat_i;
          when x"05" => can0_can_tx_data(31 downto 0) <= wb_dat_i;
          when x"06" => can0_can_tx_data(63 downto 32) <= wb_dat_i;
          when x"07" => can0_can_tx_valid <= wb_dat_i(0);
          when others => 
        end case;
      end if;
    end if;
  end process;
end BEHAVIORAL;
