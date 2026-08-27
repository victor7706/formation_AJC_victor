library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_top_dual_clock is
end tb_top_dual_clock;

architecture sim of tb_top_dual_clock is

    -- Valeurs reduites pour la simulation (voir remarque en-tete)
    constant MAX_COUNT_SIM : unsigned(27 downto 0) := to_unsigned(20, 28);
    constant N_BLINKS_SIM  : integer := 10;

    component top_dual_clock_unsync is
        generic (
            MAX_COUNT : unsigned(27 downto 0) := to_unsigned(100_000_000, 28);
            N_BLINKS  : integer := 10
        );
        Port (
            clkA     : in  STD_LOGIC;
            clkB     : in  STD_LOGIC;
            resetn   : in  STD_LOGIC;
            led0_r_o : out STD_LOGIC;
            led0_g_o : out STD_LOGIC;
            led0_b_o : out STD_LOGIC;
            led1_r_o : out STD_LOGIC;
            led1_g_o : out STD_LOGIC;
            led1_b_o : out STD_LOGIC
        );
    end component;

    signal clkA, clkB : std_logic := '0';
    signal resetn      : std_logic := '1';

    signal led0_r, led0_g, led0_b : std_logic;
    signal led1_r, led1_g, led1_b : std_logic;

begin

    ----------------------------------------------------------------------
    -- DUT : remplacer par top_dual_clock_sync pour tester la correction
    ----------------------------------------------------------------------
    DUT : top_dual_clock_unsync
        generic map (
            MAX_COUNT => MAX_COUNT_SIM,
            N_BLINKS  => N_BLINKS_SIM
        )
        port map (
            clkA     => clkA,
            clkB     => clkB,
            resetn   => resetn,
            led0_r_o => led0_r,
            led0_g_o => led0_g,
            led0_b_o => led0_b,
            led1_r_o => led1_r,
            led1_g_o => led1_g,
            led1_b_o => led1_b
        );

    ----------------------------------------------------------------------
    -- Generation des horloges
    ----------------------------------------------------------------------
    clkA_gen : process
    begin
        clkA <= '0';
        wait for 2 ns;
        clkA <= '1';
        wait for 2 ns;   -- periode 4 ns = 250 MHz
    end process;

    clkB_gen : process
    begin
        clkB <= '0';
        wait for 10 ns;
        clkB <= '1';
        wait for 10 ns;  -- periode 20 ns = 50 MHz
    end process;

    ----------------------------------------------------------------------
    -- Reset et duree de simulation
    ----------------------------------------------------------------------
    stim_proc : process
    begin
        resetn <= '1';
        wait for 50 ns;
        resetn <= '0';

        wait for 200 us;

        report "Fin de simulation" severity note;
        std.env.stop;
    end process;

end sim;
