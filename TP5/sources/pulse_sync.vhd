library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pulse_sync is
    Port (
        clk_src   : in  STD_LOGIC;  -- horloge du domaine source
        clk_dst   : in  STD_LOGIC;  -- horloge du domaine destination
        resetn    : in  STD_LOGIC;  -- reset global, actif haut (asynchrone)

        pulse_in  : in  STD_LOGIC;  -- impulsion 1 coup d'horloge, domaine clk_src
        pulse_out : out STD_LOGIC   -- impulsion 1 coup d'horloge, domaine clk_dst
    );
end pulse_sync;

architecture rtl of pulse_sync is

    -- Domaine source
    signal toggle_src : std_logic := '0';

    -- Domaine destination : chaine de synchronisation a 3 etages
    attribute ASYNC_REG : string;

    signal sync_ff1 : std_logic := '0';
    signal sync_ff2 : std_logic := '0';
    signal sync_ff3 : std_logic := '0';

    attribute ASYNC_REG of sync_ff1 : signal is "TRUE";
    attribute ASYNC_REG of sync_ff2 : signal is "TRUE";
    attribute ASYNC_REG of sync_ff3 : signal is "TRUE";

begin

    -- domaine source : transforme l'impulsion en niveau (toggle)
    process(clk_src, resetn)
    begin
        if resetn = '1' then
            toggle_src <= '0';
        elsif rising_edge(clk_src) then
            if pulse_in = '1' then
                toggle_src <= not toggle_src;
            end if;
        end if;
    end process;

    
    -- domaine destination : synchronisation puis detection de front

    process(clk_dst, resetn)
    begin
        if resetn = '1' then
            sync_ff1 <= '0';
            sync_ff2 <= '0';
            sync_ff3 <= '0';
        elsif rising_edge(clk_dst) then
            sync_ff1 <= toggle_src;  -- capture potentiellement metastable
            sync_ff2 <= sync_ff1;    -- la metastabilite s'est resorbee
            sync_ff3 <= sync_ff2;    -- reference pour la detection de front
        end if;
    end process;

    pulse_out <= sync_ff2 xor sync_ff3;

end rtl;
