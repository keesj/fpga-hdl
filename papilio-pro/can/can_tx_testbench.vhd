library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity can_tx_testbench is
end can_tx_testbench;

architecture behavior of can_tx_testbench is

    component can_tx
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
    end component;

    signal clk         :   std_logic := '0';            
    signal can_id      :   std_logic_vector (31 downto 0) := (others => '0'); -- 32 bit can_id + eff/rtr/err flags 
    signal can_dlc     :   std_logic_vector (3 downto 0) := (others => '0');
    signal can_data    :   std_logic_vector (63 downto 0) := (others => '0');
    signal can_valid   :   std_logic := '0';
    signal can_start   :   std_logic:= '0';
    signal status      :  std_logic_vector (31 downto 0):= (others => '0');
    signal can_phy_tx     :   std_logic:= '0';
    signal can_phy_tx_en  :   std_logic:= '0';
    signal can_phy_rx     :  std_logic:= '0';

    constant clk_period : time := 10 ns;

begin
    uut: can_tx port map(
        clk => clk, 
        can_id  => can_id,
        can_dlc => can_dlc,
        can_data   => can_data,
        can_valid  => can_valid,
        can_start  => can_start,
        status     => status,
        can_phy_tx  => can_phy_tx,
        can_phy_tx_en  => can_phy_tx_en,
        can_phy_rx     => can_phy_rx
    );


   clk_process :process
   begin
        clk <= '0';
        wait for clk_period/2;  --for 0.5 ns signal is '0'.
        clk <= '1';
        wait for clk_period/2;  --for next 0.5 ns signal is '1'.
   end process;

  -- Test bench statements
  tb : process
  begin
    wait for 10 ns; -- wait until global set/reset completes
    -- add user defined stimulus here

    can_id(31 downto 21)  <= "00000010100";
    can_id(0) <= '0';
    can_dlc <= "0001";
    can_data  <= X"0100000000000000" ;

    can_valid <= '1';   
    wait until rising_edge(clk);
    wait until falling_edge(clk);
    can_valid <= '0';
    wait until status(0) ='0';

    can_id(31 downto 21)  <= "00001111000";
    can_id(0) <= '0';
    can_dlc <= "0000";
    can_data  <= X"1122334455667788" ;
    can_valid <= '1';   
    wait until rising_edge(clk);
    wait until falling_edge(clk);
    can_valid <= '0';
    wait until status(0) ='0';

    can_id(31 downto 21)  <= "00000101000";
    can_id(0) <= '0';

    can_dlc <= "0001";
    can_data  <= X"1122334455667788" ;
    can_valid <= '1';   
    wait until rising_edge(clk);
    wait until falling_edge(clk);
    can_valid <= '0';
    wait until status(0) ='0';

    can_id(31 downto 21)  <= "00000101000";
    can_id(0) <= '0';
    can_dlc <= "0010";
    can_data  <= X"1122334455667788" ;
    can_valid <= '1';
    wait until rising_edge(clk);
    wait until falling_edge(clk);
    can_valid <= '0';
    wait until status(0) ='0';

    --based on 
    --https://github.com/EliasOenal/sigrok-dumps/blob/master/can/arbitrary_traffic/bsd_license_can_standard_500k.logicdata
    can_id(31 downto 21)  <= "0000" & "0001101";
    can_id(0) <= '0';
    can_dlc <= "1000";
    can_data  <= X"436f707972696768" ;
    can_valid <= '1';
    wait until rising_edge(clk);
    wait until falling_edge(clk);
    can_valid <= '0';
    wait until status(0) ='0';
    wait; -- will wait forever
  end process tb; 
end;
