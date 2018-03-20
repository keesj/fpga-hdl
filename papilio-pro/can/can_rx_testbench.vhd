library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity can_rx_testbench is
end can_rx_testbench;

architecture behavior of can_rx_testbench is
    signal clk         :   std_logic := '0';            
    signal can_id      :   std_logic_vector (31 downto 0) := (others => '0'); -- 32 bit can_id + eff/rtr/err flags 
    signal can_dlc     :   std_logic_vector (3 downto 0) := (others => '0');
    signal can_data    :   std_logic_vector (63 downto 0) := (others => '0');
    signal can_valid   :   std_logic := '0';
    signal can_clr     :   std_logic := '0';-- clear buffers
    signal status      :  std_logic_vector (31 downto 0):= (others => '0');
    signal can_signal_set : std_logic := '0';
    signal can_clk_sync   :   std_logic := '0';
    signal can_phy_tx     :   std_logic:= '0';
    signal can_phy_tx_en  :   std_logic:= '0';
    signal can_phy_rx     :  std_logic:= '1';


    signal can_tx_out         : std_logic_vector(126 downto 0) := (others =>'1');
    signal can_tx_out_len     : integer := 0;

    signal can_tx_out_input         : std_logic_vector(126 downto 0) := (others =>'1');
    signal can_tx_out_len_input     : integer := 0;


    constant clk_period : time := 10 ns;

begin
    uut: entity work.can_rx port map(
        clk => clk, 
        can_id  => can_id,
        can_dlc => can_dlc,
        can_data   => can_data,
        can_valid  => can_valid,
        can_clr => can_clr,
        status     => status,
        can_signal_get => can_signal_set,
        can_clk_sync => can_clk_sync,
        can_phy_tx  => can_phy_tx,
        can_phy_tx_en  => can_phy_tx_en,
        can_phy_rx     => can_phy_rx
    );

   --can_signal_set <=clk;

   clk_process :process
   begin
        clk <= '0';
        can_signal_set <= '0';
        wait for clk_period/2;  --for 0.5 ns signal is '0'.
        clk <= '1';
        can_signal_set <= '1';
        wait for clk_period/2;  --for next 0.5 ns signal is '1'.
   end process;

   data_out :process(clk)
   begin
        if rising_edge(clk) 
        then
            if can_clr = '1' then
                report "Set base value";
                can_tx_out     <= can_tx_out_input;
                can_tx_out_len <= can_tx_out_len_input;
            end if;
            if can_signal_set ='1'  then
                if can_tx_out_len > 0 then
                    --report "SHIFT";
                    can_phy_rx     <= can_tx_out(126);
                    can_tx_out     <= can_tx_out(125 downto 0) & '1';
                    can_tx_out_len <= can_tx_out_len -1;
                else 
                    can_phy_rx <= '1';
                end if;
            end if;
        end if;
   end process;

  -- Test bench statements
  tb : process
    file testbench_data : text open READ_MODE is "can_rx_testbench_data.hex";

    file testbench_out : text open WRITE_MODE is "can_rx_testbench_data_out.hex";
    variable l : line;
    variable out_l : line;
    --00014 0 01 0122334455667788 5C70
    variable can_in_id_expected : std_logic_vector(10 downto 0);
    variable can_in_rtr_expected : std_logic;
    variable can_in_dlc_expected : std_logic_vector(3 downto 0);  
    variable can_in_data_expected : std_logic_vector(63 downto 0);
    variable can_out_len_to_send : std_logic_vector(7 downto 0);
    variable can_tx_out_to_send :  std_logic_vector(126 downto 0);
  begin

    wait for 10 ns; -- wait until global set/reset completes
    while not endfile(testbench_data) loop
        --ID  R 
        --00d 0 8 436f707972696768 6F 7FFF8234421B7B83E2E4D2CED1D1F07F # https://github.com/EliasOenal/sigrok-dumps/blob/master/can/arbitrary_traffic/bsd_license_can_standard_500k.logicdata
        --read in the same format as the can tx example
        readline(testbench_data,l);
        hread(l, can_in_id_expected);
        read(l,  can_in_rtr_expected);
        hread(l, can_in_dlc_expected);
        hread(l, can_in_data_expected);
        hread(l, can_out_len_to_send);
        hread(l, can_tx_out_to_send);


        can_tx_out_len_input <= to_integer(unsigned(can_out_len_to_send));
        --can_tx_out_len_input <= 15;
        can_tx_out_input <= can_tx_out_to_send;
        

        can_clr <= '1'; 
        wait until rising_edge(clk);
        wait until falling_edge(clk);
        can_clr <= '0';

        wait until status(0) ='0';
        report "DONE";
    end loop;
    wait; -- will wait forever
  end process tb; 
end;
