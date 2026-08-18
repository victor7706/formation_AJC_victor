library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_driver is
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
end top_driver;


architecture rtl of top_driver is

    ------------------------------------------------
    -- Composant led_driver
    ------------------------------------------------
    component led_driver is
        generic (
            MAX_COUNT : unsigned(27 downto 0) :=
                "0000000000000000000000000111"
        );

        Port (
            clk         : in  STD_LOGIC;
            resetn      : in  STD_LOGIC;
            bouton_0    : in  STD_LOGIC;
            bouton_1    : in  STD_LOGIC;

            color_code  : in  STD_LOGIC_VECTOR(1 downto 0);
            update_o    : out STD_LOGIC;

            led_r_o     : out STD_LOGIC;
            led_g_o     : out STD_LOGIC;
            led_b_o     : out STD_LOGIC;
            end_cycle_o : out STD_LOGIC
        );
    end component;


    ------------------------------------------------
    -- Composant fifo_generator_0 (IP Vivado)
    ------------------------------------------------
    component fifo_generator_0
        PORT (
            clk   : IN  STD_LOGIC;
            srst  : IN  STD_LOGIC;
            din   : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
            wr_en : IN  STD_LOGIC;
            rd_en : IN  STD_LOGIC;
            dout  : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            full  : OUT STD_LOGIC;
            empty : OUT STD_LOGIC
        );
    end component;


    ------------------------------------------------
    -- Signaux internes
    ------------------------------------------------

    -- Code couleur brut, calculé depuis bouton_1,
    -- écrit dans la FIFO
    signal color_in_s  : std_logic_vector(1 downto 0);

    -- Code couleur lu en sortie de la FIFO,
    -- envoyé vers led_driver
    signal color_out_s : std_logic_vector(1 downto 0);

    -- Impulsion d'écriture (front montant de bouton_0,
    -- générée par led_driver)
    signal update_s     : std_logic;

    -- Impulsion de fin de cycle (générée par led_driver),
    -- utilisée pour lire la FIFO
    signal end_cycle_s  : std_logic;

    -- FIFO
    signal fifo_full_s  : std_logic;
    signal fifo_empty_s : std_logic;


begin

    ------------------------------------------------
    -- Calcul du code couleur brut selon bouton_1
    --
    -- bouton_1 = 1 -> vert ("10")
    -- bouton_1 = 0 -> bleu ("11")
    ------------------------------------------------

    color_in_s <= "10" when bouton_1 = '1' else "11";


    ------------------------------------------------
    -- Instance de la FIFO
    ------------------------------------------------

    fifo_inst : fifo_generator_0
        PORT MAP (
            clk   => clk,
            srst  => resetn,
            din   => color_in_s,
            wr_en => update_s,
            rd_en => end_cycle_s,
            dout  => color_out_s,
            full  => fifo_full_s,
            empty => fifo_empty_s
        );


    ------------------------------------------------
    -- Instance de led_driver
    ------------------------------------------------

    led_driver_inst : led_driver
        generic map (
            MAX_COUNT => MAX_COUNT
        )
        port map (
            clk         => clk,
            resetn      => resetn,
            bouton_0    => bouton_0,
            bouton_1    => bouton_1,

            color_code  => color_out_s,
            update_o    => update_s,

            led_r_o     => led_r_o,
            led_g_o     => led_g_o,
            led_b_o     => led_b_o,
            end_cycle_o => end_cycle_s
        );

    end_cycle_o <= end_cycle_s;

end rtl;