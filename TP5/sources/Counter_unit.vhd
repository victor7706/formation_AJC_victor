library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Counter_unit is
    generic (
        MAX_COUNT : unsigned(27 downto 0) := to_unsigned(7, 28)
    );

    Port ( clk         : in  STD_LOGIC;
           resetn      : in  STD_LOGIC;
           end_counter : out STD_LOGIC
           );
end Counter_unit;

architecture rtl of Counter_unit is

signal counter       : unsigned(27 downto 0);
signal end_counter_s : std_logic;

begin

    end_counter <= end_counter_s;

    process(clk, resetn)
    begin

        if resetn = '1' then
            counter       <= (others => '0');
            end_counter_s <= '0';

        elsif rising_edge(clk) then
            -- si le compteur atteint la valeur souhaitee on reinitialise
            -- le compteur et met end_counter a 1
            if counter = MAX_COUNT then
                end_counter_s <= '1';
                counter       <= (others => '0');

            -- s'il n'a toujours pas atteint la valeur max alors on
            -- incremente le compteur de +1
            else
                counter       <= counter + 1;
                end_counter_s <= '0';

            end if;
        end if;
    end process;

end rtl;