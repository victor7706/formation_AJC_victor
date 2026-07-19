library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Counter_unit is
    generic (
        MAX_COUNT : unsigned(27 downto 0):= "1011111010111100000111111111"
    );
    
    Port ( clk : in STD_LOGIC;
           resetn : in STD_LOGIC;
           end_counter : out STD_LOGIC
           );
end Counter_unit;

architecture rtl of Counter_unit is
    
    
signal counter: unsigned(27 downto 0);
signal end_counter_s: std_logic;


begin

end_counter <= end_counter_s;

    process(clk, resetn)
    
    begin
    
        if resetn ='1' then
            counter <= (others => '0');
            end_counter_s <= '0';
        
        elsif rising_edge(clk) then               
            --si le compteur atteint la valeur souhaitée on réinitialise le compteur et met end_compteur à 1    
            if counter = MAX_COUNT then -- 199 999 999 (dec) = 1011111010111100000111111111 binaire
                end_counter_s <= '1';
                counter <= (others => '0');    
            
            --s'il n'a toujours pas atteint la valeur max alors on incrémente le compteur de +1
            else
                counter <= counter +1;
                end_counter_s <= '0'; --on met end_couteur à zéro lorsqu'il n'a pas sa valeur max 
                
            end if; 
        end if;
    end process;
    
end rtl;
