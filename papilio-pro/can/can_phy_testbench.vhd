LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY can_phy_testbench IS
END can_phy_testbench;
 
ARCHITECTURE behavior OF can_phy_testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT can_phy
    PORT(
         tx : IN  std_logic;
         tx_en : IN  std_logic;
         rx : OUT  std_logic;
 	 can_collision : OUT  std_logic;
         can_l : INOUT  std_logic;
         can_h : INOUT  std_logic
        );
    END COMPONENT;
    
   --Inputs
   signal tx : std_logic := '0';
   signal tx_en : std_logic := '0';

   --BiDirs
   signal can_l : std_logic;
   signal can_h : std_logic;

   --Outputs
   signal rx : std_logic;
   signal can_collision : std_logic;
	
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: can_phy PORT MAP (
          tx => tx,
          tx_en => tx_en,
          rx => rx,
          can_l => can_l,
          can_h => can_h
        );



   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      tx<='1';
      wait for clk_period*10;
      
      tx<='0';
      wait for clk_period*10;
      
      tx_en<='1';
      wait for clk_period*10;
      
      tx<='1';
      wait for clk_period*10;
      
      tx<='0';
      wait for clk_period*10;
      
      tx_en<='0';
      wait for clk_period*10;
      -- insert stimulus here 

      wait;
   end process;
END;
