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
			status      : out std_logic_vector (32 downto 0);

			can_phy_tx     : out  std_logic;
			can_phy_tx_en  : out  std_logic;
			can_phy_rx     : in std_logic
	);
end can_tx;

architecture rtl of can_tx is
    signal can_id_buf   : std_logic_vector (31 downto 0) := (others => '0');-- 32 bit can_id + eff/rtr/err flags 
    signal can_dlc_buf  : std_logic_vector (3 downto 0) := (others => '0');
    signal can_data_buf : std_logic_vector (63 downto 0) := (others => '0');

	signal shift_buff : std_logic_vector (63 downto 0) := (others => '0');

	signal can_bit_time_counter : signed (7 downto 0) := (others => '0');		
	signal can_bit_count : signed (7 downto 0) := (others => '0');		

	-- sff(11 bit) and eff (29 bit)  is set in the msb  of can_id
	alias  can_sff_buf  : std_logic_vector is can_id_buf(10 downto 0) ;
	alias  can_eff_buf  : std_logic is can_id_buf(31);
	alias  can_ert_buf  : std_logic is can_id_buf(30);

	-- State
	type can_tx_states is (
  		can_tx_idle,
  		can_tx_start_of_frame,
		can_tx_arbitration_field,
  		can_tx_control_field,
  		can_tx_crc_field,
		can_tx_ack_field,
		can_tx_end_of_frame_field,
		can_tx_interface_field
	);

	signal can_tx_state: can_tx_states := can_tx_idle;
begin

	count: process(clk)
	begin
		if rising_edge(clk) then
			can_bit_time_counter <= can_bit_time_counter +1;	

			if can_bit_time_counter = 10 then
				can_bit_time_counter <= (others => '0');
				case can_tx_state is
					when can_tx_idle =>
							if can_valid = '1' then
								--copy the data to the internal signal
								can_id_buf <= can_id;
								can_dlc_buf <= can_dlc;
								can_data_buf <= can_data;
								can_tx_state <= can_tx_start_of_frame;
								report "HAHA";
							end if;
					when can_tx_start_of_frame =>
						report "SOF";
						can_tx_state <= can_tx_arbitration_field;	
						can_phy_tx <= '0';
						can_phy_tx_en  <='1';
						can_bit_count <= X"0b";
						shift_buff(63 downto 53) <= can_id_buf(31 downto 21) ;
					when can_tx_arbitration_field =>
						report "ARB";
					    can_bit_count <= can_bit_count -1;
						shift_buff <= shift_buff(62 downto 0) & shift_buff(63);
						can_phy_tx <= shift_buff(63);
						can_phy_tx_en  <='1';						
						if can_bit_count = "0000000" then
							can_tx_state <= can_tx_idle;
							can_phy_tx_en  <= '0';
						end if;	
					when others =>
						report "OTHER";
						can_tx_state <= can_tx_idle;
				end case;
			end if;
		end if;
	end process;
end rtl;

