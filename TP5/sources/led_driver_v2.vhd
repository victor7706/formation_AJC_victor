library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity led_driver_v2 is
    generic (
        MAX_COUNT : unsigned(27 downto 0) := to_unsigned(100_000_000, 28)
    );
    Port (
        clk           : in  STD_LOGIC;
        resetn        : in  STD_LOGIC;  

        color_code    : in  STD_LOGIC_VECTOR(1 downto 0);
        update_i      : in  STD_LOGIC;  -- impulsion 1 coup d'horloge : change de couleur

        led_r_o       : out STD_LOGIC;
        led_g_o       : out STD_LOGIC;
        led_b_o       : out STD_LOGIC;

        blink_pulse_o : out STD_LOGIC   
    );
end led_driver_v2;

architecture rtl of led_driver_v2 is

    component Counter_unit is
        generic (
            MAX_COUNT : unsigned(27 downto 0) := to_unsigned(100_000_000, 28)
        );
        Port (
            clk         : in  STD_LOGIC;
            resetn      : in  STD_LOGIC;
            end_counter : out STD_LOGIC
        );
    end component;

    type state_t is (ROUGE, VERT, BLEU);
    signal state : state_t := ROUGE;

    signal end_counter_s : std_logic;

    signal led_r_s : std_logic := '0';
    signal led_g_s : std_logic := '0';
    signal led_b_s : std_logic := '0';

    signal cpt : unsigned(0 downto 0) := (others => '0');

    signal blink_pulse_s : std_logic := '0';

begin

    uut1 : Counter_unit
        generic map (
            MAX_COUNT => MAX_COUNT
        )
        port map (
            clk         => clk,
            resetn      => resetn,
            end_counter => end_counter_s
        );

    led_r_o       <= led_r_s;
    led_g_o       <= led_g_s;
    led_b_o       <= led_b_s;
    blink_pulse_o <= blink_pulse_s;

    process(clk, resetn)
    begin
        if resetn = '1' then

            state         <= ROUGE;
            led_r_s       <= '0';
            led_g_s       <= '0';
            led_b_s       <= '0';
            cpt           <= (others => '0');
            blink_pulse_s <= '0';

        elsif rising_edge(clk) then

            blink_pulse_s <= '0';  

            if update_i = '1' then

                led_r_s <= '0';
                led_g_s <= '0';
                led_b_s <= '0';
                cpt     <= (others => '0');

                case color_code is
                    when "01"   => state <= ROUGE;
                    when "10"   => state <= VERT;
                    when "11"   => state <= BLEU;
                    when others => state <= ROUGE;
                end case;

            elsif end_counter_s = '1' then

                -- Clignotement de la couleur actuelle
                case state is
                    when ROUGE => led_r_s <= not led_r_s;
                    when VERT  => led_g_s <= not led_g_s;
                    when BLEU  => led_b_s <= not led_b_s;
                end case;

                cpt <= cpt + 1;

                if cpt(0) = '1' then
                    
                    blink_pulse_s <= '1';
                end if;

            end if;

        end if;
    end process;

end rtl;
