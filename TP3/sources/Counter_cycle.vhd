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

entity Counter_cycle is
    generic (
        MAXBIT    : integer := 3
        );
        
    Port ( clk            : in  STD_LOGIC;
           resetn         : in  STD_LOGIC;
           end_counter_i  : in STD_LOGIC;
           reset_cycle_i  : in STD_LOGIC;
           cycle_counter_o: out STD_LOGIC_VECTOR(MAXBIT - 1 downto 0)
           );
end Counter_cycle;

architecture rtl of Counter_cycle is

    ------------------------------------------------
    -- Signaux internes
    ------------------------------------------------
    signal cycle_counter_s    : unsigned(MAXBIT - 1 downto 0);
    
begin

    cycle_counter_o <= std_logic_vector(cycle_counter_s);

    
        ------------------------------------------------
    -- Process principal
    ------------------------------------------------
process(clk, resetn)
begin

    if resetn = '1' then

        cycle_counter_s <= (others => '0');

    elsif rising_edge(clk) then

        if reset_cycle_i = '1' then

            cycle_counter_s <= (others => '0');

        elsif end_counter_i = '1' then

            cycle_counter_s <= cycle_counter_s + 1;

        end if;
        
        --cycle_counter_s <= (others => '0');
        
    end if;
    

end process;

end rtl;
