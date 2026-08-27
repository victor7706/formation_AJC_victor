library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_single_clock is
    generic (
        MAX_COUNT : unsigned(27 downto 0) := to_unsigned(100_000_000, 28);
        N_BLINKS  : integer := 10
    );
    Port (
        clk      : in  STD_LOGIC;
        resetn   : in  STD_LOGIC;

        led0_r_o : out STD_LOGIC;
        led0_g_o : out STD_LOGIC;
        led0_b_o : out STD_LOGIC;

        led1_r_o : out STD_LOGIC;
        led1_g_o : out STD_LOGIC;
        led1_b_o : out STD_LOGIC
    );
end top_single_clock;

architecture rtl of top_single_clock is

    component led_driver_v2 is
        generic (
            MAX_COUNT : unsigned(27 downto 0) := to_unsigned(100_000_000, 28)
        );
        Port (
            clk           : in  STD_LOGIC;
            resetn        : in  STD_LOGIC;
            color_code    : in  STD_LOGIC_VECTOR(1 downto 0);
            update_i      : in  STD_LOGIC;
            led_r_o       : out STD_LOGIC;
            led_g_o       : out STD_LOGIC;
            led_b_o       : out STD_LOGIC;
            blink_pulse_o : out STD_LOGIC
        );
    end component;

    component color_sequencer is
        generic (
            N_BLINKS : integer := 10
        );
        Port (
            clk           : in  STD_LOGIC;
            resetn        : in  STD_LOGIC;
            blink_pulse_i : in  STD_LOGIC;
            update_o      : out STD_LOGIC;
            color_code_o  : out STD_LOGIC_VECTOR(1 downto 0)
        );
    end component;

    signal update_s     : std_logic;
    signal color_code_s : std_logic_vector(1 downto 0);
    signal blink_led0_s : std_logic;

begin

    -- Le sequenceur ne compte que les blinks de la LED0 : c'est elle
    -- qui "donne le tempo" du changement de couleur (cf. question 4).
    seq_inst : color_sequencer
        generic map (
            N_BLINKS => N_BLINKS
        )
        port map (
            clk           => clk,
            resetn        => resetn,
            blink_pulse_i => blink_led0_s,
            update_o      => update_s,
            color_code_o  => color_code_s
        );

    led0_inst : led_driver_v2
        generic map (
            MAX_COUNT => MAX_COUNT
        )
        port map (
            clk           => clk,
            resetn        => resetn,
            color_code    => color_code_s,
            update_i      => update_s,
            led_r_o       => led0_r_o,
            led_g_o       => led0_g_o,
            led_b_o       => led0_b_o,
            blink_pulse_o => blink_led0_s
        );

    led1_inst : led_driver_v2
        generic map (
            MAX_COUNT => MAX_COUNT
        )
        port map (
            clk           => clk,
            resetn        => resetn,
            color_code    => color_code_s,
            update_i      => update_s,
            led_r_o       => led1_r_o,
            led_g_o       => led1_g_o,
            led_b_o       => led1_b_o,
            blink_pulse_o => open  -- non utilise, LED1 n'est pas maitre du tempo
        );

end rtl;
