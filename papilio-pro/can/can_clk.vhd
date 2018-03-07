library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity can_clk is
    port ( clk : in std_logic;
           rst : in std_logic;
           can_bus_value : in  std_logic;         -- The current value of the but. used to detect edges and adapt the clock
           can_sample_set_clk : out  std_logic;   -- Signal an outgoing sample must be set (firest quanta)
           can_sample_check_clk : out  std_logic; -- Signal the value of a signal can be checked to detect collision
           can_sample_get_clk : out  std_logic);  -- Singal that the incommint sample can be read
end can_clk;

architecture rtl of can_clk is
        signal quanta_counter :integer := 0;
        signal counter :integer := 0;
        signal can_sample_set_clk_buf : std_logic := '0';
        signal can_sample_check_clk_buf : std_logic := '0';
        signal can_sample_get_clk_buf :  std_logic := '0';
        signal divider : integer := 500;
begin
    can_sample_set_clk <= can_sample_set_clk_buf;
    can_sample_check_clk <= can_sample_check_clk_buf;
    can_sample_get_clk <= can_sample_get_clk_buf;
    -- Input clock is 100 mhz
    -- Can bit time if 500.000 hence we want 10 faster
    -- 500 khz
    count: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                -- start with counter =0 to ensure the 
                -- next clock cycle the code gets triggered imediately
                counter <= 0;
                quanta_counter <= 0;
            else
                can_sample_set_clk_buf <= '0';
                can_sample_check_clk_buf <= '0';
                can_sample_get_clk_buf <= '0' ;

                counter <= counter - 1;
                if counter = 0 then
                    counter <= divider;
                    quanta_counter <= quanta_counter +1;
                    if quanta_counter = 10 then
                    quanta_counter <= 0;
                    end if;

                    if 
                        quanta_counter = 0 
                    then
                        can_sample_set_clk_buf <= '1';
                    elsif  quanta_counter = 8 
                    then
                        can_sample_get_clk_buf <= '1';
                    else 
                        can_sample_check_clk_buf <= '1';
                    end if;
                end if;
            end if; 
        end if;
    end process;
end rtl;
