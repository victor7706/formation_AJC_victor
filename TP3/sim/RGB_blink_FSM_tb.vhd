library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity RGB_blink_FSM_tb is
end RGB_blink_FSM_tb;

architecture tb of RGB_blink_FSM_tb is

component RGB_blink_FSM is
    generic (
        MAXBIT    : integer := 3;
        MAX_COUNT : unsigned(27 downto 0):= "0000000000000000000000000110" --10dec
        );
        
    Port ( clk          : in  STD_LOGIC;
           resetn       : in  STD_LOGIC;
           restart      : in  STD_LOGIC;
           
           led_r_o      : out STD_LOGIC;
           led_g_o      : out STD_LOGIC;
           led_b_o      : out STD_LOGIC
           );
end component;


-- signals
constant MAX_COUNT  : unsigned(27 downto 0) := "0000000000000000000000000110"; 
constant MAXBIT     : integer := 3;
signal clk          : std_logic := '0';
signal resetn       : std_logic := '0';
signal restart      : std_logic:= '0';
signal led_r_o      : std_logic;
signal led_g_o      : std_logic;
signal led_b_o      : std_logic;
    
begin

    -- DUT instantiation
    uut1: RGB_blink_FSM
            generic map (
            MAX_COUNT => MAX_COUNT,
            MAXBIT    => MAXBIT
        )
        port map (
            clk         => clk,
            resetn      => resetn,
            restart     => restart,
            led_r_o     => led_r_o,
            led_g_o     => led_g_o,
            led_b_o     => led_b_o
        );



clk <= not clk after 5 ns;

    stim_proc : process
    begin
        resetn <= '1';
        wait for 30 ns;

        resetn <= '0';
       
        wait for 4000ns;
        restart <= '1';
        
        wait for 20 ns;
        restart <= '0';
        
        wait for 350 ns;
        
        resetn <= '0';
        wait for 200 ns;
        
    end process;
   

end tb;
