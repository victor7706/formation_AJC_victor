library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity led_driver_tb is
end led_driver_tb;

architecture rtl of led_driver_tb is


    component led_driver is
    generic (
        MAX_COUNT : unsigned(27 downto 0) :=
            "0000000000000000000000000111"
    );

    Port (
        clk      : in  STD_LOGIC;
        resetn   : in  STD_LOGIC;
        bouton_0 : in  STD_LOGIC;
        bouton_1 : in  STD_LOGIC;

        led_r_o  : out STD_LOGIC;
        led_g_o  : out STD_LOGIC;
        led_b_o  : out STD_LOGIC;
        end_cycle_o: out STD_LOGIC
    );
end component;

-- signals
constant MAX_COUNT  : unsigned(27 downto 0) := "0000000000000000000000000111"; --7dec
signal clk          : std_logic := '0';
signal resetn         : std_logic := '0';
signal bouton_0  : std_logic:= '0';
signal bouton_1 :  STD_LOGIC:= '0';
signal led_r_o: std_logic:= '0';
signal led_g_o  :  STD_LOGIC:= '0';
signal led_b_o  :  STD_LOGIC:= '0';
signal end_cycle_o : STD_LOGIC:= '0';

begin

    uut1: led_driver
            generic map (
            MAX_COUNT => MAX_COUNT
        )
        port map (
            clk          => clk,
            resetn         => resetn,
            bouton_0  => bouton_0,
            bouton_1  => bouton_1,
            led_r_o  => led_r_o,
            led_g_o  => led_g_o,
            led_b_o  => led_b_o,
            end_cycle_o => end_cycle_o
        );

   
    clk <= not clk after 5 ns;

    stim_proc : process
begin

        ------------------------------------------------
        -- RESET
        ------------------------------------------------

        resetn <= '1';

        bouton_0 <= '0';
        bouton_1 <= '0';

        wait for 20 ns;

        resetn <= '0';

        wait for 20 ns;


        ------------------------------------------------
        -- Sélection du VERT
        --
        -- bouton_1 = 1
        ------------------------------------------------

        bouton_1 <= '1';

        wait for 20 ns;


        ------------------------------------------------
        -- Appui sur bouton_0
        --
        -- 0 -> 1
        ------------------------------------------------

        bouton_0 <= '1';

        wait for 10 ns;


        ------------------------------------------------
        -- Maintien du bouton
        --
        -- update ne doit PAS rester à 1
        ------------------------------------------------

        wait for 30 ns;


        ------------------------------------------------
        -- Relâchement du bouton
        --
        -- 1 -> 0
        ------------------------------------------------

        bouton_0 <= '0';

        wait for 30 ns;


        ------------------------------------------------
        -- On laisse le vert clignoter
        ------------------------------------------------

        wait for 300 ns;


        ------------------------------------------------
        -- Sélection du BLEU
        --
        -- bouton_1 = 0
        ------------------------------------------------

        bouton_1 <= '0';

        wait for 20 ns;


        ------------------------------------------------
        -- Appui sur bouton_0
        --
        -- nouveau update
        ------------------------------------------------

        bouton_0 <= '1';

        wait for 10 ns;


        ------------------------------------------------
        -- Maintien
        ------------------------------------------------

        wait for 30 ns;


        ------------------------------------------------
        -- Relâchement
        ------------------------------------------------

        bouton_0 <= '0';

        wait for 100 ns;


        ------------------------------------------------
        -- FIN DE SIMULATION
        ------------------------------------------------



bouton_1 <= '1';

        wait for 20 ns;


        ------------------------------------------------
        -- Appui sur bouton_0
        --
        -- 0 -> 1
        ------------------------------------------------

        bouton_0 <= '1';

        wait for 10 ns;


        ------------------------------------------------
        -- Maintien du bouton
        --
        -- update ne doit PAS rester à 1
        ------------------------------------------------

        wait for 30 ns;


        ------------------------------------------------
        -- Relâchement du bouton
        --
        -- 1 -> 0
        ------------------------------------------------

        bouton_0 <= '0';

        wait for 30 ns;


        ------------------------------------------------
        -- On laisse le vert clignoter
        ------------------------------------------------

        wait for 300 ns;


        ------------------------------------------------
        -- Sélection du BLEU
        --
        -- bouton_1 = 0
        ------------------------------------------------

        bouton_1 <= '0';

        wait for 20 ns;


        ------------------------------------------------
        -- Appui sur bouton_0
        --
        -- nouveau update
        ------------------------------------------------

        bouton_0 <= '1';

        wait for 10 ns;


        ------------------------------------------------
        -- Maintien
        ------------------------------------------------

        wait for 30 ns;


        ------------------------------------------------
        -- Relâchement
        ------------------------------------------------

        bouton_0 <= '0';

        wait for 100 ns;
        
        
        wait;

    end process;

    
end rtl;