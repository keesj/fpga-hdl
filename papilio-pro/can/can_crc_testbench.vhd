LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY can_crc_testbench IS
END can_crc_testbench;

ARCHITECTURE behavior OF can_crc_testbench IS 

  -- Component Declaration
  COMPONENT can_crc
   Port ( clk : in  STD_LOGIC;
           reset : in STD_LOGIC;
           ce : in  STD_LOGIC;
           din : in  STD_LOGIC;
           crc : out  STD_LOGIC_VECTOR(14 downto 0)
    );
  END COMPONENT;

  
END;
