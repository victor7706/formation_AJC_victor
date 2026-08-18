library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity led_driver is
    generic (
        MAX_COUNT : unsigned(27 downto 0) :=
            "0000000000000000000000000111"
    );

    Port (
        clk      : in  STD_LOGIC;
        --resetn   : in  STD_LOGIC;
        bouton_0 : in  STD_LOGIC;
        bouton_1 : in  STD_LOGIC;

        led_r_o  : out STD_LOGIC;
        led_g_o  : out STD_LOGIC;
        led_b_o  : out STD_LOGIC
    );
end led_driver;


architecture rtl of led_driver is

    component Counter_unit is
        generic (
            MAX_COUNT : unsigned(27 downto 0) :=
                "0000000000000000000000000111"
        );

        Port (
            clk         : in  STD_LOGIC;
            resetn      : in  STD_LOGIC;
            end_counter : out STD_LOGIC
        );
    end component;


    ------------------------------------------------
    -- Etats de la FSM
    ------------------------------------------------
    type state_t is (INIT, ROUGE, VERT, BLEU);
    signal state : state_t := INIT;


    ------------------------------------------------
    -- Signaux internes
    ------------------------------------------------
    signal resetn_s: std_logic := '0';
    
    signal end_counter_s : std_logic;

    signal cycle_counter : unsigned(2 downto 0);

    signal bouton_0_prev : std_logic;

    signal led_r_s : std_logic;
    signal led_g_s : std_logic;
    signal led_b_s : std_logic;

    -- Couleur choisie par bouton_1
    signal color_code : std_logic_vector(1 downto 0);

    -- Couleur réellement mémorisée
    signal current_color : std_logic_vector(1 downto 0);

    -- Impulsion générée lors de l'appui sur bouton_0
    signal update_s : std_logic;


begin

    ------------------------------------------------
    -- Compteur
    ------------------------------------------------

    uut1 : Counter_unit
        generic map (
            MAX_COUNT => MAX_COUNT
        )
        port map (
            clk         => clk,
            resetn      => resetn_s,
            end_counter => end_counter_s
        );


    ------------------------------------------------
    -- Connexion des sorties
    ------------------------------------------------

    led_r_o <= led_r_s;
    led_g_o <= led_g_s;
    led_b_o <= led_b_s;


    ------------------------------------------------
    -- Choix de la couleur avec bouton_1
    -- bouton_1 = 1 -> vert
    -- bouton_1 = 0 -> bleu
    ------------------------------------------------

    color_code <= "10" when bouton_1 = '1' else "11";


    ------------------------------------------------
    -- Génération de UPDATE
    -- UPDATE = 1 pendant un seul cycle lors
    -- du passage de bouton_0 de 0 à 1
    ------------------------------------------------

    update_process : process(clk, resetn_s)
    begin

        if resetn_s = '1' then

            bouton_0_prev <= '0';
            update_s      <= '0';

        elsif rising_edge(clk) then

            if bouton_0 = '1' and bouton_0_prev = '0' then
                update_s <= '1';
            else
                update_s <= '0';
            end if;

            bouton_0_prev <= bouton_0;

        end if;

    end process update_process;


    ------------------------------------------------
    -- FSM
    ------------------------------------------------

    process(clk, resetn_s)
    begin

        if resetn_s = '1' then

            state         <= INIT;

            led_r_s       <= '0';
            led_g_s       <= '0';
            led_b_s       <= '0';

            cycle_counter <= (others => '0');

            current_color <= "00";

        elsif rising_edge(clk) then

            ------------------------------------------------
            -- Mémorisation de la couleur
            -- current_color ne change QUE lors de UPDATE
            ------------------------------------------------

            if update_s = '1' then
                current_color <= color_code;
            end if;


            ------------------------------------------------
            -- FSM
            ------------------------------------------------

            case state is

                ------------------------------------------------
                -- Etat initial
                ------------------------------------------------

                when INIT =>

                    led_r_s <= '0';
                    led_g_s <= '0';
                    led_b_s <= '0';

                    state <= ROUGE;


                ------------------------------------------------
                -- Etat ROUGE
                ------------------------------------------------

                when ROUGE =>

                    led_g_s <= '0';
                    led_b_s <= '0';

                    -- Si une nouvelle couleur est validée
                    if update_s = '1' then

                        if color_code = "10" then

                            state <= VERT;
                            led_r_s <= '0';

                        elsif color_code = "11" then

                            state <= BLEU;
                            led_r_s <= '0';

                        end if;

                    else

                        -- Clignotement rouge
                        if end_counter_s = '1' then
                            led_r_s <= not led_r_s;
                        end if;

                    end if;


                ------------------------------------------------
                -- Etat VERT
                ------------------------------------------------

                when VERT =>

                    led_r_s <= '0';
                    led_b_s <= '0';

                    -- Si une nouvelle couleur est validée
                    if update_s = '1' then

                        if color_code = "11" then

                            state <= BLEU;
                            led_g_s <= '0';

                        elsif color_code = "10" then

                            state <= VERT;

                        end if;

                    else

                        -- Clignotement vert
                        if end_counter_s = '1' then
                            led_g_s <= not led_g_s;
                        end if;

                    end if;


                ------------------------------------------------
                -- Etat BLEU
                ------------------------------------------------

                when BLEU =>

                    led_r_s <= '0';
                    led_g_s <= '0';

                    -- Si une nouvelle couleur est validée
                    if update_s = '1' then

                        if color_code = "10" then

                            state <= VERT;
                            led_b_s <= '0';

                        elsif color_code = "11" then

                            state <= BLEU;

                        end if;

                    else

                        -- Clignotement bleu
                        if end_counter_s = '1' then
                            led_b_s <= not led_b_s;
                        end if;

                    end if;


                when others =>

                    state <= INIT;

            end case;

        end if;

    end process;


end rtl;