library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_Counter_unit is
    generic (
        MAX_COUNT : unsigned(27 downto 0);
        MAXBIT    : integer := 10
    );
    Port ( clk            : in  STD_LOGIC;
           resetn         : in  STD_LOGIC;
           end_counter    : out STD_LOGIC;
           cycle_counter_o: out STD_LOGIC_VECTOR(MAXBIT - 1 downto 0)
           );
end top_Counter_unit;

architecture rtl of top_Counter_unit is
    ------------------------------------------------
    -- Déclaration du composant Counter_unit
    ------------------------------------------------
    component Counter_unit
        generic (
            MAX_COUNT : unsigned(27 downto 0)
        );
        Port (
            clk         : in  STD_LOGIC;
            resetn      : in  STD_LOGIC;
            end_counter : out STD_LOGIC
        );
    end component;

    ------------------------------------------------
    -- Signaux internes
    ------------------------------------------------
    
    signal cycle_counter_s    : unsigned(MAXBIT - 1 downto 0);

begin


    cycle_counter_o <= std_logic_vector(cycle_counter_s);

    -- Détection de front montant : garantit un pulse d'1 cycle
    -- quel que soit la largeur réelle de end_counter_s

    ------------------------------------------------
    -- Instanciation du compteur
    ------------------------------------------------
    counter_inst : Counter_unit
        generic map(
            MAX_COUNT => MAX_COUNT
        )
        port map(
            clk         => clk,
            resetn      => resetn
            
        );

    ------------------------------------------------
    -- Process principal
    ------------------------------------------------
    process(clk, resetn)
    begin
        if resetn = '1' then
            cycle_counter_s  <= (others => '0');

        elsif rising_edge(clk) then
            -- Mémorisation pour détection de front au cycle suivant
            end_counter_prev <= end_counter_s;

            -- Logique de comptage : elsif garantit une seule
            -- écriture non ambiguë sur trigger_s par cycle
            if trigger_s = "01" and end_counter_pulse = '1' then
                cycle_counter_s <= cycle_counter_s + 1;
                trigger_s       <= "00";
            elsif end_counter_pulse = '1' then
                trigger_s <= trigger_s + 1;
            end if;

        end if;
    end process;

end rtl;
