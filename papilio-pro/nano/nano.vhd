library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
 
entity nano is
    port(
    indata: in std_logic;
    outdata: out std_logic;
    sysclk: in std_logic
    );
end nano;    
 
architecture rtl of nano is
signal rst: std_logic:='0';
begin  
    process(sysclk)
    variable buf: std_logic_vector(2 downto 0);
    variable state: std_logic;
    begin      
        if rising_edge(sysclk) then
            if rst = '0' then
                rst<='1';
                buf:="000";
                state:='0';
            else
                buf:=buf(1 downto 0)&indata;
                if buf = "111" then
                    state:='1';
                elsif buf = "000" then
                    state:='0';
                end if;
            end if;
            outdata<=state;
        end if;
    end process;
end rtl;
