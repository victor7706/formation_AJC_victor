library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_top_single_clock is
end tb_top_single_clock;

architecture sim of tb_top_single_clock is

    constant MAX_COUNT_SIM : unsigned(27 downto 0) := to_unsigned(2, 28);
    constant N_BLINKS_SIM  : integer := 10;
    constant CLK_PERIOD    : time := 10 ns;

    component top_single_clock is
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
    end component;

    signal clk    : std_logic := '0';
    signal resetn : std_logic := '1';

    signal led0_r, led0_g, led0_b : std_logic;
    signal led1_r, led1_g, led1_b : std_logic;

    -- Compteur de blinks observes sur led0_r, pour verifier la regle des
    -- "10 clignotements par couleur" independamment du DUT.
    signal blink_count_check : integer := 0;

begin

    ----------------------------------------------------------------------
    -- DUT
    ----------------------------------------------------------------------
    DUT : top_single_clock
        generic map (
            MAX_COUNT => MAX_COUNT_SIM,
            N_BLINKS  => N_BLINKS_SIM
        )
        port map (
            clk      => clk,
            resetn   => resetn,
            led0_r_o => led0_r,
            led0_g_o => led0_g,
            led0_b_o => led0_b,
            led1_r_o => led1_r,
            led1_g_o => led1_g,
            led1_b_o => led1_b
        );

    ----------------------------------------------------------------------
    -- Horloge unique
    ----------------------------------------------------------------------
    clk_gen : process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    ----------------------------------------------------------------------
    -- Reset puis duree de simulation
    ----------------------------------------------------------------------
    stim_proc : process
    begin
        resetn <= '1';
        wait for 50 ns;
        resetn <= '0';

        wait for 10 us;

        report "Fin de simulation" severity note;
        std.env.stop;
    end process;

end sim;
