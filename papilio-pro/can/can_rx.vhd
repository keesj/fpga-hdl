library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity can_rx is
    port (  clk            : in  std_logic;            
            can_id         : out  std_logic_vector (31 downto 0);-- 32 bit can_id + eff/rtr/err flags 
            can_dlc        : out  std_logic_vector (3 downto 0);
            can_data       : out  std_logic_vector (63 downto 0);
            can_valid      : out  std_logic;
            can_clr        : in std_logic; -- allow to recieve a frame
            status         : out std_logic_vector (31 downto 0);
            can_signal_get : in std_logic; -- signal to set/change a value on the bus
            can_clk_sync   : out std_logic; -- signal to synchronize the clock with values on the bus
            can_phy_tx     : out  std_logic; -- needed to ack
            can_phy_tx_en  : out  std_logic; -- needed to ack 
            can_phy_rx     : in std_logic
    );
end can_rx;

architecture rtl of can_rx is
    signal can_id_buf   : std_logic_vector (31 downto 0) := (others => '0');-- 32 bit can_id + eff/rtr/err flags 
    signal can_dlc_buf  : std_logic_vector (3 downto 0) := (others => '0');
    signal can_data_buf : std_logic_vector (63 downto 0) := (others => '0');
    signal can_crc_buf : std_logic_vector (14 downto 0) := (others => '0');
    signal can_crc_buf_recieved : std_logic_vector (14 downto 0) := (others => '0');
    signal shift_buff : std_logic_vector (127 downto 0) := (others => '0');
    signal buff_current : std_logic_vector (127 downto 0) := (others => '0');
    -- Counter used to count the bits sent
    signal can_bit_counter : unsigned (7 downto 0) := (others => '0');
    

    -- Two buffers to keep the last bits sent to detect when we need bit stuffing
    --https://en.wikipedia.org/wiki/CAN_bus#Bit_stuffing
    --CAN uses NRZ encoding and bit stuffing
    --After 5 identical bits, a stuff bit of opposite value is added.
    --But not in the CRC delimiter, ACK, and end of frame fields.
    signal bit_shift_one_bits : std_logic_vector(4 downto 0) := (others =>'0');
    signal bit_shift_zero_bits : std_logic_vector(4 downto 0) := (others => '1');
    --alias can_logic_bit_next : std_logic is shift_buff(127);

    ---- sff(11 bit) and eff (29 bit)  is set in the msb  of can_id
    -- Code kept here as as start of extended mode support
    --alias  can_sff_buf  : std_logic_vector is can_id_buf(10 downto 0) ;
    --alias  can_eff_buf  : std_logic is can_id_buf(31);

    -- The lsb of the can_id register signifies a can rtr packet
    alias  can_rtr  : std_logic is can_id_buf(30);

    -- State
    type can_states is (
          can_state_idle,
          can_state_start_of_frame, -- 1 bit
          can_state_arbitration,    -- 12 bit = 11 bit id + req remote
          can_state_control,        -- 6 bit  = id-ext + 0 + 4 bit dlc
          can_state_data,           -- 0-64 bits (8 * dlc)
          can_state_crc,            -- 15 bits + 1 bit crc delimiter
          can_state_ack_slot,       -- 1 bit
          can_state_ack_delimiter,  -- 1 bit 
          can_state_eof             -- 7 bit
    );

    signal can_rx_state: can_states := can_state_idle;

    signal needs_stuffing : std_logic := '0';
    signal stuffing_value : std_logic := '0';
    signal current_rx_value : std_logic := '0';

    signal stuffing_enabled : std_logic := '1';

    signal crc_din : std_logic := '0';
    signal crc_ce : std_logic := '0';
    signal crc_rst : std_logic := '0';
    signal crc_data : std_logic_vector(14 downto 0);
begin

    crc: entity work.can_crc port map(
        clk => clk,
        din => crc_din,
        ce => crc_ce,
        rst => crc_rst,
        crc => crc_data
      );

    -- status / next state logic
    -- bit[0] of the status register signifies the logic is busy. the rest is unused
    status(0) <= '0' when can_rx_state = can_state_idle else '1';
    status(31 downto 1) <= (others => '0');

    -- The bit shift buffers are filled for evey bit time
    needs_stuffing <= '1' when  (bit_shift_one_bits = "11111" or bit_shift_zero_bits = "00000") and stuffing_enabled = '1'  else '0';
    stuffing_value <= '0' when  bit_shift_one_bits = "11111"  else '1';

    current_rx_value <= can_phy_rx;
    -- For crc we never take stuffing into account and look at the current bit sent out
    crc_din <= shift_buff(0);

    -- this forms the buffer we want to look into looking at the current values of the buffer
    buff_current <= shift_buff(126 downto 0) & current_rx_value;

    count: process(clk)
    begin
        if rising_edge(clk) then
            -- For crc we need to assert the signal only for one clock cycle hence we reset
            -- to 0 every cycle
            crc_ce <= '0';
            can_clk_sync <= '0';
            if can_clr = '1' then
                report "CAN CLEAR";
                -- Empty internal buffers
                can_id_buf <= (others => '0');
                can_dlc_buf <= (others => '0');
                can_data_buf <= (others => '0');
                can_valid <= '0';
            end if;

            -- starting happens starting with a 0 bit value
            if can_phy_rx ='0' and (can_rx_state = can_state_idle) then
                report "CAN START";
                stuffing_enabled <='1';
                -- and prepare next fields
                -- 13 bits  <= start of frame + id (11 bit) + rtr
                shift_buff <= (others => '0');    
                can_bit_counter <= (others => '0');
                can_rx_state <= can_state_start_of_frame;
                --reset stuffing (enable is done in SOF)
                bit_shift_one_bits <= (others => '0');
                bit_shift_zero_bits  <= (0=>'0' , others => '1');
                crc_rst <= '1';
                can_clk_sync <= '1';
            elsif can_signal_get = '1' then
                --report "STATE " & can_states'image(can_rx_state) ;
                if needs_stuffing = '1' and stuffing_enabled ='1' then
                    report "RX STUFFING(SKIPPING)";
                    bit_shift_one_bits <= (0=> '1' , others => '0');
                    bit_shift_zero_bits  <= (0=>'0', others => '1');
                else
                    --shift bits in
                    shift_buff(127 downto 0) <= buff_current;
                    bit_shift_one_bits <= bit_shift_one_bits(3 downto 0) & current_rx_value;
                    bit_shift_zero_bits <= bit_shift_zero_bits(3 downto 0) & current_rx_value;

                    can_bit_counter <= can_bit_counter +1; 
                    crc_rst <= '0';
                    case can_rx_state is
                        when can_state_idle =>
                            --report "IDLE";
                            stuffing_enabled <='0';
                            crc_ce <= '0';
                        when can_state_start_of_frame =>
                            report "SOF";
                            stuffing_enabled <='1';
                            crc_ce <= '1';
                            --perpare next state
                            can_bit_counter <= (others => '0');
                            can_rx_state <= can_state_arbitration;
                        when can_state_arbitration =>
                            report "AR bytes";
                            crc_ce <= '1';
                            if can_bit_counter = 10  then
                                --prare next state
                                --shift_buff(127 downto 115) <= '0' & can_id(31 downto 21) & can_id(0);
                                report "AR DONE " &  to_hstring(buff_current(11 downto 1));
                                can_id_buf <= (others => '0');
                                can_id_buf(31 downto 21) <= buff_current(11 downto 1);
                                can_id_buf(0)<= buff_current(0);
                                can_bit_counter <=(others => '0');
                                can_rx_state <= can_state_control;
                            end if;
                        when can_state_control =>
                            report "Control bytes";
                            crc_ce <= '1';
                            if can_bit_counter = 5 then
                                report "DLC " &  to_hstring(buff_current(3 downto 0));
                                can_dlc_buf <= buff_current(3 downto 0);
                                can_bit_counter <=(others => '0');
                                if buff_current(3 downto 0) = "0000" then
                                    can_rx_state <= can_state_crc;
                                    -- the next bit is going to be the CRC do not update crc
                                    crc_ce <= '0';
                                else 
                                    can_rx_state <= can_state_data;
                                end if;
                            end if;
                        when can_state_data =>
                            report "Data";
                            crc_ce <= '1';
                            
                            if can_bit_counter = (8 * unsigned(can_dlc_buf)) -1   then
                                -- the next bit is going to be the CRC do not update crc
                                for i in 1 to 8 loop
                                    if i = unsigned(can_dlc_buf) then
                                        can_data_buf((i * 8) -1 downto 0) <=   buff_current((i * 8) -1 downto 0);
                                    end if;
                                end loop;
                                
                                crc_ce <= '1';
                                can_bit_counter <= (others => '0');
                                can_rx_state <= can_state_crc;
                            end if;
                        when can_state_crc =>
                            report "CRC";
                            if can_bit_counter = 1 then
                                can_crc_buf <= crc_data;-- this is the recalculated recived buffer
                            end if;
                            if can_bit_counter = 14 then
                                can_crc_buf_recieved <= buff_current(14 downto 0);
                                can_bit_counter <= (others => '0');
                                can_rx_state <= can_state_ack_delimiter;
                                crc_rst <= '1';
                                -- push ack slot and delimiter
                                shift_buff(127 downto 126) <= "0" & "1";
                            end if;
                        when can_state_ack_slot =>
                            can_bit_counter <= (others => '0');
                            can_rx_state <= can_state_ack_delimiter;
                        when can_state_ack_delimiter => 
                            can_bit_counter <= (others => '0');
                            can_rx_state <= can_state_eof;
                        when can_state_eof =>
                            can_id <= can_id_buf;
                            can_dlc <= can_dlc_buf;
                            can_data <= can_data_buf;
                            can_valid <= '1';
                            -- disable stuffing for those bits
                            stuffing_enabled <='0';
                            if can_bit_counter = 6 then
                                can_rx_state <= can_state_idle;
                            end if;                            
                    end case;
                end if;
            end if;
        end if;
    end process;
end rtl;
