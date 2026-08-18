library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity led_driver is
    generic (
        MAX_COUNT : unsigned(27 downto 0) :=
            "0000000000000000000000000111"
    );

    Port (
        clk         : in  STD_LOGIC;
        resetn      : in  STD_LOGIC;
        bouton_0    : in  STD_LOGIC;
        bouton_1    : in  STD_LOGIC;

        -- Couleur reçue en sortie de la FIFO externe
        color_code  : in  STD_LOGIC_VECTOR(1 downto 0);

        -- Impulsion d'écriture, à destination du wr_en de la FIFO
        update_o    : out STD_LOGIC;

        led_r_o     : out STD_LOGIC;
        led_g_o     : out STD_LOGIC;
        led_b_o     : out STD_LOGIC;
        end_cycle_o : out STD_LOGIC
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



    -- Etats de la FSM

    type state_t is (INIT, ROUGE, VERT, BLEU);
    signal state : state_t := INIT;



    -- Signaux internes


    signal end_counter_s : std_logic;

    -- Signaux pour la détection de fin de cycle
    signal cycle_phase_s : std_logic := '0';
    signal end_cycle_s   : std_logic;

    signal bouton_0_prev : std_logic;

    signal led_r_s : std_logic;
    signal led_g_s : std_logic;
    signal led_b_s : std_logic;

    -- Impulsion générée lors de l'appui sur bouton_0
    signal update_s : std_logic;

    signal led_on_s : std_logic;

    signal cpt : unsigned(5 downto 0);


begin

 
    -- Compteur


    uut1 : Counter_unit
        generic map (
            MAX_COUNT => MAX_COUNT
        )
        port map (
            clk         => clk,
            resetn      => resetn,
            end_counter => end_counter_s
        );



    -- Connexion des sorties


    led_r_o <= led_r_s;
    led_g_o <= led_g_s;
    led_b_o <= led_b_s;

    end_cycle_o <= end_cycle_s;

  
    update_o <= update_s;


    -- Détection de fin de cycle allumé/éteint


    end_cycle_process : process(clk, resetn)
    begin

        if resetn = '1' then

            end_cycle_s <= '0';

        elsif rising_edge(clk) then

            if cpt(0) = '0' then
                end_cycle_s <= '1';
            else
                end_cycle_s <= '0';
            end if;

        end if;

    end process end_cycle_process;



    -- Génération de UPDATE
    -- UPDATE = 1 pendant un seul cycle lors
    -- du passage de bouton_0 de 0 à 1


    update_process : process(clk, resetn)
    begin

        if resetn = '1' then

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



    -- FSM


    process(clk, resetn)
    begin

        if resetn = '1' then

            state   <= INIT;

            led_r_s <= '0';
            led_g_s <= '0';
            led_b_s <= '0';

            cpt     <= (others => '0');

        elsif rising_edge(clk) then



            case state is
    
                -- Etat initial
              

                when INIT =>

                    led_r_s <= '0';
                    led_g_s <= '0';
                    led_b_s <= '0';

                    state <= ROUGE;


                
                -- Etat ROUGE
                

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
                            cpt <= cpt + 1;
                        end if;

                    end if;


                
                -- Etat VERT
               

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
                            cpt <= cpt + 1;
                        end if;

                    end if;


                
                -- Etat BLEU
                

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
                            cpt <= cpt + 1;
                        end if;

                    end if;


                when others =>

                    state <= INIT;

            end case;

        end if;

    end process;


end rtl;