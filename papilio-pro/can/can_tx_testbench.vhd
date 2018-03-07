library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity can_tx_testbench is
end can_tx_testbench;

architecture behavior of can_tx_testbench is
    signal clk         :   std_logic := '0';            
    signal can_id      :   std_logic_vector (31 downto 0) := (others => '0'); -- 32 bit can_id + eff/rtr/err flags 
    signal can_dlc     :   std_logic_vector (3 downto 0) := (others => '0');
    signal can_data    :   std_logic_vector (63 downto 0) := (others => '0');
    signal can_valid   :   std_logic := '0';
    signal status      :  std_logic_vector (31 downto 0):= (others => '0');
    signal can_signal_set : std_logic := '0';
    signal can_phy_tx     :   std_logic:= '0';
    signal can_phy_tx_en  :   std_logic:= '0';
    signal can_phy_rx     :  std_logic:= '0';

    constant clk_period : time := 10 ns;

begin
    uut: entity work.can_tx port map(
        clk => clk, 
        can_id  => can_id,
        can_dlc => can_dlc,
        can_data   => can_data,
        can_valid  => can_valid,
        status     => status,
        can_signal_set => can_signal_set,
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

  -- Test bench statements
  tb : process
    file testbench_data : text open READ_MODE is "can_tx_testbench_data.hex";
    variable l : line;
    --00014 0 01 0122334455667788 5C70
    variable can_in_id : std_logic_vector(10 downto 0);
    variable can_in_rtr : std_logic;
    variable can_in_dlc : std_logic_vector(3 downto 0);  
    variable can_in_data : std_logic_vector(63 downto 0);
    variable can_in_crc : std_logic_vector(14 downto 0);
  begin

    wait for 10 ns; -- wait until global set/reset completes
    while not endfile(testbench_data) loop
        readline(testbench_data,l);
        hread(l, can_in_id);
        read(l,  can_in_rtr);
        hread(l, can_in_dlc);
        hread(l, can_in_data);
        hread(l, can_in_crc);

        can_id(31 downto 21) <= can_in_id;
        can_id(0) <= can_in_rtr;
        can_dlc <= can_in_dlc;
        can_data <= can_in_data;

        can_valid <= '1'; 
        wait until rising_edge(clk);
        wait until falling_edge(clk);
        can_valid <= '0';
        wait until status(0) ='0';
    end loop;
    wait; -- will wait forever
  end process tb; 
end;
