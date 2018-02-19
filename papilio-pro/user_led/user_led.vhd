library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity user_led is
    port (
           led : out  STD_LOGIC);
end user_led;

architecture Behavioral of user_led is

begin
    led <= '1';
end Behavioral;

