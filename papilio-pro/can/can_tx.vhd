library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity can_tx is
    port (  clk         : in  std_logic;            
    
            can_id      : in  std_logic_vector (31 downto 0);-- 32 bit can_id + eff/rtr/err flags 
            can_dlc     : in  std_logic_vector (3 downto 0);
            can_data    : in  std_logic_vector (63 downto 0);
            can_valid   : in  std_logic;
            can_start   : in  std_logic;
            status      : out std_logic_vector (31 downto 0);
            can_phy_tx     : out  std_logic;
            can_phy_tx_en  : out  std_logic;
            can_phy_rx     : in std_logic
    );
end can_tx;

architecture rtl of can_tx is
    signal can_id_buf   : std_logic_vector (31 downto 0) := (others => '0');-- 32 bit can_id + eff/rtr/err flags 
    signal can_dlc_buf  : std_logic_vector (3 downto 0) := (others => '0');
    signal can_data_buf : std_logic_vector (63 downto 0) := (others => '0');

    signal can_crc_buf : std_logic_vector (14 downto 0) := (others => '0');
    
    signal shift_buff : std_logic_vector (127 downto 0) := (others => '0');
    signal can_bit_time_counter : unsigned (7 downto 0) := (others => '0');
    signal can_bit_counter : unsigned (7 downto 0) := (others => '0');

    -- two buffers to keep the last bits sent
    --https://en.wikipedia.org/wiki/CAN_bus#Bit_stuffing
    --CAN uses NRZ encoding and bit stuffing
    --After 5 identical bits, a stuff bit of opposite value is added.
    --But not in the CRC delimiter, ACK, and end of frame fields.
    signal bit_shift_one_bits : std_logic_vector(4 downto 0) := (others =>'0');
    signal bit_shift_zero_bits : std_logic_vector(4 downto 0) := (others => '1');
    alias can_logic_bit_next : std_logic is shift_buff(127);

    -- sff(11 bit) and eff (29 bit)  is set in the msb  of can_id
    alias  can_sff_buf  : std_logic_vector is can_id_buf(10 downto 0) ;
    alias  can_eff_buf  : std_logic is can_id_buf(31);
    alias  can_rtr  : std_logic is can_id_buf(30);

    signal can_valid_has_been_low : std_logic := '1';

    
    -- State
    type can_tx_states is (
          can_tx_idle,
          can_tx_start_of_frame, -- 1 bit
        can_tx_arbitration,    -- 12 bit = 11 bit id + req remote
        can_tx_control,        -- 6 bit  = id-ext + 0 + 4 bit dlc
        can_tx_data,           -- 0-64 bits (0 + 8 * dlc)
          can_tx_crc,            -- 15 bits + 1 bit crc delimiter
        can_tx_ack_slot,       -- 1 bit
        can_tx_ack_delimiter,  -- 1 bit 
        can_tx_eof             -- 7 bit
    );

    signal can_tx_state: can_tx_states := can_tx_idle;
    signal needs_stuffing : std_logic := '0';
    signal stuffing_value : std_logic := '0';
    signal next_tx_value : std_logic := '0';
    signal stuffing_enabled : std_logic := '1';

    signal crc_din : std_logic := '0';
    signal crc_ce : std_logic := '0';
    signal crc_rst : std_logic := '0';
    signal crc_data : std_logic_vector(14 downto 0);
    
    component can_crc 
        port ( 
                clk : in  std_logic;
                din : in  std_logic;
                ce : in std_logic;
                rst : in std_logic;
                crc : out  std_logic_vector(14 downto 0)
        );
    end component;
begin

    crc: can_crc port map(
        clk => clk,
        din => crc_din,
        ce => crc_ce,
        rst => crc_rst,
        crc => crc_data
      );

    --crc_din <= shift_buff(127);

    -- status / next state logic
    status(0) <= '0' when can_tx_state = can_tx_idle else '1';
    status(31 downto 1) <= (others => '0');
    needs_stuffing <= '1' when  (bit_shift_one_bits = "11111" or bit_shift_zero_bits = "00000") and stuffing_enabled = '1'  else '0';
    stuffing_value <= '0' when  bit_shift_one_bits = "11111"  else '1';
    next_tx_value <= stuffing_value when needs_stuffing = '1' else shift_buff(127);
    crc_din <= shift_buff(127);
    
    count: process(clk)
    begin
        if rising_edge(clk) then
            crc_ce <= '0';
            can_bit_time_counter <= can_bit_time_counter +1;

            if can_valid ='0' then
                can_valid_has_been_low <= '1';
            end if;

            if can_valid ='1' and can_valid_has_been_low = '1' and can_tx_state = can_tx_idle then
                report "CANUP";
                can_valid_has_been_low <= '0';
                --copy the data to the internal buffers
                can_id_buf <= can_id;
                can_dlc_buf <= can_dlc;
                can_data_buf <= can_data;
                
                -- and prepare next fields
                -- 12 bits id + rtr 
                -- start of frame + id (11 bit) + rtr TODO 31-31 and 30 are overlapping !
                shift_buff(127 downto 115) <= '0' & can_id(31 downto 21)  & can_id(0);
                -- IDE + reservered + dlc
                shift_buff(114 downto 109) <= "0" & "0" & can_dlc;
                -- copy data (anyway)
                shift_buff(108 downto 45) <= can_data;
                
                can_bit_counter <= (others => '0');
                can_tx_state <= can_tx_start_of_frame;
                --reset stuffing 
                stuffing_enabled <='1';
                bit_shift_one_bits <= (others => '0');
                bit_shift_zero_bits  <= (others => '1');
                crc_rst <= '1';
            end if;

            --When to send a bit
            if can_bit_time_counter = 10 then

                can_bit_time_counter <= (others => '0');

                can_phy_tx <= next_tx_value ;
                bit_shift_one_bits <= bit_shift_one_bits(3 downto 0) & next_tx_value;
                bit_shift_zero_bits <= bit_shift_zero_bits(3 downto 0) & next_tx_value;
                
                if needs_stuffing = '1' then
                    report "STUFFING";
                    bit_shift_one_bits <= (others => '0');
                    bit_shift_zero_bits  <= (others => '1');
                else
                    --shift bits for the next round
                    shift_buff(127 downto 0) <= shift_buff(126 downto 0) & "0";
                    can_bit_counter <= can_bit_counter +1; 
                    crc_rst <= '0';
                    case can_tx_state is
                        when can_tx_idle =>
                            --report "IDLE";
                            can_phy_tx_en <= '0';
                            stuffing_enabled <='0';
                            crc_ce <= '0';
                        when can_tx_start_of_frame =>
                            report "SOF";
                            can_phy_tx_en <= '1';
                            crc_ce <= '1';
                            --perpare next state
                            can_bit_counter <= (others => '0');
                            can_tx_state <= can_tx_arbitration;
                        when can_tx_arbitration =>
                            report "AR bites";
                            crc_ce <= '1';
                            if can_bit_counter = 12 then
                                --prare next state
                                can_bit_counter <=(others => '0');
                                can_tx_state <= can_tx_control;
                            end if;
                        when can_tx_control =>
                            report "Control bites";
                            crc_ce <= '1';
                            if can_bit_counter = 5 then
                                can_bit_counter <=(others => '0');
                                if can_dlc_buf = "0000" then
                                    can_tx_state <= can_tx_crc;
                                else 
                                    can_tx_state <= can_tx_data;
                                end if;
                            end if;
                        when can_tx_data =>
                            report "Data bites";
                            crc_ce <= '1';
                            if can_bit_counter = (8 * unsigned(can_dlc_buf)) -1 then
                                can_bit_counter <= (others => '0');
                                can_tx_state <= can_tx_crc;

                                can_crc_buf <= crc_data;
                                --Add to send buffer
                                shift_buff(127 downto 112) <= crc_data & '0';
                                --shift_buff(127 downto 112) <= (others => '1');
                            end if;
                        when can_tx_crc =>
                            if can_bit_counter = 15 then
                                can_tx_state <= can_tx_ack_delimiter;
                                crc_rst <= '1';
                                -- After crc and the crc delimiter we have
                            end if;
                        when can_tx_ack_delimiter =>
                            can_tx_state <= can_tx_ack_slot;
                        when can_tx_ack_slot => 
                            can_tx_state <= can_tx_eof;
                        when can_tx_eof =>
                            -- TODO disable stuffing
                            can_tx_state <= can_tx_idle;
                    end case;
                end if;
            end if;
        end if;
    end process;
end rtl;

