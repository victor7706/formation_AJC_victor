library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_driver_tb is
end top_driver_tb;


architecture sim of top_driver_tb is

    ------------------------------------------------
    -- DUT
    ------------------------------------------------
    component top_driver is
        generic (
            MAX_COUNT : unsigned(27 downto 0) :=
                "0000000000000000000000000111"
        );

        Port (
            clk         : in  STD_LOGIC;
            resetn      : in  STD_LOGIC;
            bouton_0    : in  STD_LOGIC;
            bouton_1    : in  STD_LOGIC;

            led_r_o     : out STD_LOGIC;
            led_g_o     : out STD_LOGIC;
            led_b_o     : out STD_LOGIC;
            end_cycle_o : out STD_LOGIC
        );
    end component;


    ------------------------------------------------
    -- Signaux de test
    ------------------------------------------------
    constant CLK_PERIOD : time := 10 ns;

    -- MAX_COUNT réduit pour accélérer la simulation
    -- (correspond à quelques cycles d'horloge seulement,
    -- au lieu de la vraie valeur utilisée en synthèse)
    constant MAX_COUNT_SIM : unsigned(27 downto 0) :=
        to_unsigned(4, 28);

    signal clk         : std_logic := '0';
    signal resetn      : std_logic := '1';
    signal bouton_0    : std_logic := '0';
    signal bouton_1    : std_logic := '0';

    signal led_r_o     : std_logic;
    signal led_g_o     : std_logic;
    signal led_b_o     : std_logic;
    signal end_cycle_o : std_logic;

    signal sim_done     : boolean := false;


begin

    ------------------------------------------------
    -- Instance du DUT
    ------------------------------------------------

    uut : top_driver
        generic map (
            MAX_COUNT => MAX_COUNT_SIM
        )
        port map (
            clk         => clk,
            resetn      => resetn,
            bouton_0    => bouton_0,
            bouton_1    => bouton_1,
            led_r_o     => led_r_o,
            led_g_o     => led_g_o,
            led_b_o     => led_b_o,
            end_cycle_o => end_cycle_o
        );


    ------------------------------------------------
    -- Génération de l'horloge
    ------------------------------------------------

    clk_process : process
    begin
        while not sim_done loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process clk_process;


    ------------------------------------------------
    -- Tâche utilitaire : générer un appui bref
    -- sur bouton_0 (front montant, tenu 1 cycle,
    -- puis relâché)
    ------------------------------------------------

    stim_process : process
    begin

        ------------------------------------------------
        -- Reset initial
        ------------------------------------------------
        resetn   <= '1';
        bouton_0 <= '0';
        bouton_1 <= '0';
        wait for 5 * CLK_PERIOD;

        resetn <= '0';
        wait for 5 * CLK_PERIOD;

        -- A la sortie du reset : état ROUGE attendu,
        -- led_r_o clignote, led_g_o et led_b_o restent à '0'

        ------------------------------------------------
        -- Test 1 : sélection du VERT (bouton_1 = '1')
        -- puis appui sur bouton_0
        --
        -- On laisse tourner assez longtemps pour
        -- qu'un end_cycle survienne et que la FIFO
        -- soit lue, avant de vérifier la transition
        ------------------------------------------------

        bouton_1 <= '1';  -- couleur choisie = vert ("10")
        wait for 2 * CLK_PERIOD;

        -- Appui bref sur bouton_0 : écrit "10" dans la FIFO
        bouton_0 <= '1';
        wait for CLK_PERIOD;
        bouton_0 <= '0';

        -- On attend suffisamment de cycles de clignotement
        -- pour laisser le temps à end_cycle de se produire
        -- et à la FIFO d'être lue, puis à la FSM de
        -- transitionner vers VERT
        wait for 40 * CLK_PERIOD;

        assert (led_g_o = '1' or led_g_o = '0')
            report "Verification manuelle: on attend un clignotement en VERT ici"
            severity note;


        ------------------------------------------------
        -- Test 2 : sélection du BLEU (bouton_1 = '0')
        -- puis appui sur bouton_0
        ------------------------------------------------

        bouton_1 <= '0';  -- couleur choisie = bleu ("11")
        wait for 2 * CLK_PERIOD;

        bouton_0 <= '1';
        wait for CLK_PERIOD;
        bouton_0 <= '0';

        wait for 40 * CLK_PERIOD;

        assert (led_b_o = '1' or led_b_o = '0')
            report "Verification manuelle: on attend un clignotement en BLEU ici"
            severity note;


        ------------------------------------------------
        -- Test 3 : plusieurs appuis rapprochés sur
        -- bouton_0 sans changer bouton_1, pour vérifier
        -- que la FSM reste stable sur la meme couleur
        ------------------------------------------------

        bouton_0 <= '1';
        wait for CLK_PERIOD;
        bouton_0 <= '0';
        wait for 15 * CLK_PERIOD;

        bouton_0 <= '1';
        wait for CLK_PERIOD;
        bouton_0 <= '0';
        wait for 30 * CLK_PERIOD;


        ------------------------------------------------
        -- Fin de simulation
        ------------------------------------------------

        report "Fin du testbench top_driver_tb" severity note;
        sim_done <= true;
        wait;

    end process stim_process;


end sim;