library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity can_clk is
    port ( clk : in std_logic;
           can_bus_value : in  std_logic;         -- The current value of the but. used to detect edges and adapt the clock
           can_sample_set_clk : out  std_logic;   -- Signal an outgoing sample must be set (firest quanta)
           can_sample_check_clk : out  std_logic; -- Signal the value of a signal can be checked to detect collision
           can_sample_get_clk : out  std_logic);  -- Singal that the incommint sample can be read
end can_clk;

architecture rtl of can_clk is
        signal counter : signed (7 downto 0) := (others => '0');
begin
    -- Input clock is 100 mhz
    -- Can bit time if 500.000 hence we want 10 faster
    -- 500 khz
    count: process(clk)
    begin
        if rising_edge(clk) then
            counter <= counter +1;
            can_sample_set_clk <= counter(3);
        end if;
    end process;
    
end rtl;

