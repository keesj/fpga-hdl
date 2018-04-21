---------------------------------------------------------------------------
-- Company     :  Armadeus Systems
-- Author(s)   :  Fabien Marteau fabien.marteau@armadeus.com
--
-- Creation Date : 2013-10-17
-- File          : debounce_tb.vhd
--
-- Abstract :
--
---------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity nano_tb is
end entity nano_tb;

architecture RTL of nano_tb is

    CONSTANT HALF_PERIODE : time := 5.26315789474 ns;  -- 95Mhz

    component nano is
        port (
            indata: in std_logic;
            outdata: out std_logic;
            sysclk: in std_logic
        );
    end component;

    signal clk   : std_logic;
    signal buttons_in  : std_logic;
    signal buttons_out : std_logic;
    signal running : std_logic := '1';
begin

    debounce_con : nano

    port map(
        sysclk    => clk,
        indata  => buttons_in,
        outdata => buttons_out
    );

    stimulis : process
    begin


        -- button 0 bounce
        wait for 1.7 ms;
        buttons_in <= '0';
        wait for 1.3 ms;
        buttons_in <= '1';
        wait for 1 ms;
        buttons_in <= '0';
        wait for 0.8 ms;
        buttons_in <= '1';
        wait for 0.6 ms;
        buttons_in <= '0';
        wait for 1.7 ms;
        buttons_in <= '0';
        wait for 1.3 ms;
        buttons_in <= '1';
        wait for 1 ms;
        buttons_in <= '0';
        wait for 0.8 ms;
        buttons_in <= '1';
        wait for 0.6 ms;
        buttons_in <= '0';

        wait for 11 ms;

        buttons_in <= '1';
        wait for 1.7 ms;
        buttons_in <= '0';
        wait for 1.3 ms;
        buttons_in <= '1';
        wait for 1 ms;
        buttons_in <= '0';
        wait for 0.8 ms;
        buttons_in <= '1';
        wait for 0.6 ms;
        buttons_in <= '0';
        wait for 1.7 ms;
        buttons_in <= '0';
        wait for 1.3 ms;
        buttons_in <= '1';
        wait for 1 ms;
        buttons_in <= '0';
        wait for 0.8 ms;
        buttons_in <= '1';
        wait for 0.8 ms;
        buttons_in <= '0';


        wait for 50 ms;
        report "*** End of test ***";
        running <= '0';
        wait;
    end process stimulis;

    clockp : process
    begin
        clk <= '1';
        wait for HALF_PERIODE;
        clk <= '0';
        wait for HALF_PERIODE;
        if running ='0' then
            wait;
        end if;
    end process clockp;

    -- time counter
    time_count : process
        variable time_c : natural := 0;
    begin
        report "Time "&integer'image(time_c)&" ms";
        wait for 1 ms;
        time_c := time_c + 1;
        if running ='0' then
            wait;
        end if;
    end process time_count;

end architecture RTL;

