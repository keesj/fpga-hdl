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
			can_out_tx     : out  std_logic;
			can_out_tx_en  : out  std_logic;
			status      : out std_logic_vector (32 downto 0));
end can_tx;

architecture rtl of can_tx is

    signal can_id_buf   : std_logic_vector (31 downto 0);-- 32 bit can_id + eff/rtr/err flags 
    signal can_dlc_buf  : std_logic_vector (3 downto 0);
    signal can_data_buf : std_logic_vector (63 downto 0);

    signal can_bit_counter : signed(5 downto 0);--random shit

	-- sff(11 bit) and eff (29 bit)  is set in the msb  of can_id
	alias  can_sff_buf  : std_logic_vector is can_id_buf(10 downto 0);
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
    
	count: process(clk,can_valid)
	begin
		if rising_edge(clk) then
			-- copy data logic
			if rising_edge(can_valid) then
			  --copy the data to the internal signal
			  can_id_buf <= can_id;
			  can_dlc_buf <= can_dlc;
			  can_data_buf <= can_data;
			  can_tx_state <= can_tx_start_of_frame;
			  can_bit_counter <= "000000";
			end if;
			can_bit_counter <= can_bit_counter + 1;

			if (can_bit_counter = 100) then
				case can_tx_state is
					when can_tx_start_of_frame =>
					can_tx_state <= can_tx_idle;	
					when others =>
					can_tx_state <= can_tx_idle;
				end case;
			end if;
		end if;
	end process;
end rtl;

