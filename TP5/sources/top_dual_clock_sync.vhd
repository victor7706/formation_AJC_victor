library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_dual_clock_sync is
    generic (
        MAX_COUNT : unsigned(27 downto 0) := to_unsigned(100_000_000, 28);
        N_BLINKS  : integer := 10
    );
    Port (
        clk_in   : in  STD_LOGIC;  
        resetn   : in  STD_LOGIC;  

        led0_r_o : out STD_LOGIC;
        led0_g_o : out STD_LOGIC;
        led0_b_o : out STD_LOGIC;

        led1_r_o : out STD_LOGIC;
        led1_g_o : out STD_LOGIC;
        led1_b_o : out STD_LOGIC
    );
end top_dual_clock_sync;

architecture rtl of top_dual_clock_sync is


    -- Declaration du composant PLL 

    component clk_wiz_0 is
        port (
            clk_in1  : in  std_logic;
            reset    : in  std_logic;  
            clk_out1 : out std_logic;  -- clkA (250 MHz)
            clk_out2 : out std_logic;  -- clkB (50 MHz)
            locked   : out std_logic
        );
    end component;

  
    -- Déclaration des composants

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

    component pulse_sync is
        Port (
            clk_src   : in  STD_LOGIC;
            clk_dst   : in  STD_LOGIC;
            resetn    : in  STD_LOGIC;
            pulse_in  : in  STD_LOGIC;
            pulse_out : out STD_LOGIC
        );
    end component;

    attribute ASYNC_REG : string;

    -- clk et reset internes
    signal clkA         : std_logic;
    signal clkB         : std_logic;
    signal pll_reset    : std_logic;
    signal pll_locked   : std_logic;
    signal sys_resetn   : std_logic;

    -- domnaine clkA
    signal update_a     : std_logic;
    signal color_code_a : std_logic_vector(1 downto 0);
    signal blink_led0_s : std_logic;

    -- domaine clkB
    signal update_b        : std_logic;
    signal color_code_b_ff1 : std_logic_vector(1 downto 0) := (others => '0');
    signal color_code_b     : std_logic_vector(1 downto 0) := (others => '0');

    attribute ASYNC_REG of color_code_b_ff1 : signal is "TRUE";
    attribute ASYNC_REG of color_code_b     : signal is "TRUE";

begin


    -- Instanciation et gestion de la PLL
    
    -- J'inversion le resetn externe car la PLL veut un reset actif haut
    pll_reset <= not resetn;

    pll_inst : clk_wiz_0
        port map (
            clk_in1  => clk_in,
            reset    => pll_reset,
            clk_out1 => clkA,       -- 250 MHz
            clk_out2 => clkB,       -- 50 MHz
            locked   => pll_locked
        );

    
    sys_resetn <= resetn and pll_locked;


    -- Logique domaine clkA : sequenceur + LED0

    seq_inst : color_sequencer
        generic map (
            N_BLINKS => N_BLINKS
        )
        port map (
            clk           => clkA,
            resetn        => sys_resetn,
            blink_pulse_i => blink_led0_s,
            update_o      => update_a,
            color_code_o  => color_code_a
        );

    led0_inst : led_driver_v2
        generic map (
            MAX_COUNT => MAX_COUNT
        )
        port map (
            clk           => clkA,
            resetn        => sys_resetn,
            color_code    => color_code_a,
            update_i      => update_a,
            led_r_o       => led0_r_o,
            led_g_o       => led0_g_o,
            led_b_o       => led0_b_o,
            blink_pulse_o => blink_led0_s
        );

 
    -- passage de domaine clkA -> clkB

    psync_inst : pulse_sync
        port map (
            clk_src   => clkA,
            clk_dst   => clkB,
            resetn    => sys_resetn,
            pulse_in  => update_a,
            pulse_out => update_b
        );

    -- Synchronisation simple du bus color_code (signal lent et stable)
    -- Correction de la polarite du reset (resetn actif a '0')
    process(clkB, sys_resetn)
    begin
        if sys_resetn = '0' then
            color_code_b_ff1 <= (others => '0');
            color_code_b     <= (others => '0');
        elsif rising_edge(clkB) then
            color_code_b_ff1 <= color_code_a;
            color_code_b     <= color_code_b_ff1;
        end if;
    end process;

 
    -- Logique domaine clkB : LED1

    led1_inst : led_driver_v2
        generic map (
            MAX_COUNT => MAX_COUNT
        )
        port map (
            clk           => clkB,
            resetn        => sys_resetn,
            color_code    => color_code_b,
            update_i      => update_b,
            led_r_o       => led1_r_o,
            led_g_o       => led1_g_o,
            led_b_o       => led1_b_o,
            blink_pulse_o => open
        );

end rtl;