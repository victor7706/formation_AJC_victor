----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.07.2026 17:01:14
-- Design Name: 
-- Module Name: RGB_blink_FSM - rtl
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RGB_blink_FSM is
    generic (
        MAXBIT    : integer := 3;
        MAX_COUNT : unsigned(27 downto 0):= "1011111010111100000111111111";
        FULL_CYCLE : unsigned(2 downto 0):= "110"
        );
        
    Port ( clk          : in  STD_LOGIC;
           resetn       : in  STD_LOGIC;
           restart      : in  STD_LOGIC;
           
           led_r_o      : out STD_LOGIC;
           led_g_o      : out STD_LOGIC;
           led_b_o      : out STD_LOGIC
           );
end RGB_blink_FSM;


architecture rtl of RGB_blink_FSM is

    -- component declaration
    component Counter_unit is
    generic (
        MAX_COUNT : unsigned(27 downto 0):= "1011111010111100000111111111"
    );
    
    Port ( clk : in STD_LOGIC;
           resetn : in STD_LOGIC;
           end_counter : out STD_LOGIC
           );
end component;



component Counter_cycle is
    generic (
        MAXBIT    : integer := 3
        );
        
    Port ( clk            : in  STD_LOGIC;
           resetn         : in  STD_LOGIC;
           end_counter_i    : in STD_LOGIC;
           reset_cycle_i  : in STD_LOGIC;
           cycle_counter_o: out STD_LOGIC_VECTOR(MAXBIT - 1 downto 0)
           );
end component;


---ILA
COMPONENT ila_0
    PORT (
	   clk : IN STD_LOGIC;

	   probe0 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
	   probe1 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
	   probe2 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
	   probe3 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
	   probe4 : IN STD_LOGIC_VECTOR(0 DOWNTO 0)
);
END COMPONENT  ;


------------------------------------------------
-- Etats de la FSM
------------------------------------------------
type state_t is (INIT, ROUGE, BLEU, VERT);

signal state : state_t;


------------------------------------------------
-- Signaux internes
------------------------------------------------

signal end_counter_s: std_logic;
signal reset_cycle_s: std_logic;
signal cycle_counter_s: std_logic_vector(MAXBIT - 1 downto 0);

signal led_r_s: std_logic;
signal led_g_s: std_logic;
signal led_b_s: std_logic;
    
begin

    -- DUT instantiation
    uut1: Counter_unit
            generic map (
            MAX_COUNT => MAX_COUNT
        )
        port map (
            clk          => clk,
            resetn         => resetn,
            end_counter  => end_counter_s
        );
        
         -- DUT instantiation
    uut2: Counter_cycle
            generic map (
            MAXBIT => MAXBIT
        )
        port map (
            clk          => clk,
            resetn         => resetn,
            end_counter_i => end_counter_s,
            reset_cycle_i => reset_cycle_s,
            cycle_counter_o  => cycle_counter_s
        );

reset_cycle_s <= '1' when (unsigned(cycle_counter_s) = to_unsigned(6, MAXBIT))
                       or (restart = '1')
                  else '0';


led_r_o <= led_r_s; 
led_g_o <= led_g_s;    
led_b_o <= led_b_s;             
                  
process(clk, resetn)
    
    begin
        
        if resetn ='1' then
        
            state <= INIT; 
            --reset_cycle_s <= '0';
            
            led_r_s <= '0';
            led_g_s <= '0';
            led_b_s <= '0';
            
        elsif rising_edge(clk) then
            led_r_s <= '0';
            led_g_s <= '0';
            led_b_s <= '0';
            --reset_cycle_s <= '0';
                         
            if restart = '1' then
                state <= INIT;
                --reset_cycle_s <= '1';
                
            else 
                case state is 
                    when INIT =>
                        if cycle_counter_s = std_logic_vector(FULL_CYCLE) then --6
                            state <= ROUGE;
                            --reset_cycle_s <= '1';
                        else 
                            if cycle_counter_s(0) = '0' then
                                led_r_s <= '1';
                                led_g_s <= '1';
                                led_b_s <= '1';
                            else 
                                led_r_s <= '0';
                                led_g_s <= '0';
                                led_b_s <= '0';
                            end if;
                        end if;
                        
                      when ROUGE =>
                        if cycle_counter_s = std_logic_vector(FULL_CYCLE) then --6
                            state <= BLEU;
                            --reset_cycle_s <= '1';
                        else 
                            if cycle_counter_s(0) = '0' then
                                led_r_s <= '1';
                                led_g_s <= '0';
                                led_b_s <= '0';
                            else 
                                led_r_s <= '0';
                                led_g_s <= '0';
                                led_b_s <= '0';
                               
                            end if;
                         end if;
                         
                         
                    when BLEU =>
                        if cycle_counter_s = std_logic_vector(FULL_CYCLE) then --5
                            state <= VERT;
                            --reset_cycle_s <= '1';
                        else 
                            if cycle_counter_s(0) = '0' then
                                led_r_s <= '0';
                                led_g_s <= '0';
                                led_b_s <= '1';
                            else 
                                led_r_s <= '0';
                                led_g_s <= '0';
                                led_b_s <= '0';
                               
                            end if;
                         end if;
                         
                     when VERT =>
                        if cycle_counter_s = std_logic_vector(FULL_CYCLE) then --5
                            state <= ROUGE;
                            --reset_cycle_s <= '1';
                        else 
                            if cycle_counter_s(0) = '0' then
                                led_r_s <= '0';
                                led_g_s <= '1';
                                led_b_s <= '0';
                            else 
                                led_r_s <= '0';
                                led_g_s <= '0';
                                led_b_s <= '0';
                               
                            end if;
                         end if;
                         
                         
                end case;
             end if;    
        end if;
    end process;

your_instance_name : ila_0
PORT MAP (
	clk => clk,
	probe0(0) => resetn, 
	probe1(0) => restart, 
	probe2(0) => led_r_s, 
	probe3(0) => led_g_s, 
	probe4(0) => led_b_s
);

    
end rtl;
