library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity color_sequencer is
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
end color_sequencer;

architecture rtl of color_sequencer is

    signal blink_cnt  : unsigned(3 downto 0) := (others => '0');
    signal color_reg  : std_logic_vector(1 downto 0) := "01"; -- depart : ROUGE
    signal update_reg : std_logic := '0';

begin

    process(clk, resetn)
    begin
        if resetn = '1' then

            blink_cnt  <= (others => '0');
            color_reg  <= "01";
            update_reg <= '0';

        elsif rising_edge(clk) then

            update_reg <= '0';  

            if blink_pulse_i = '1' then

                if blink_cnt = to_unsigned(N_BLINKS - 1, blink_cnt'length) then

                    blink_cnt <= (others => '0');

                    case color_reg is
                        when "01"   => color_reg <= "11";  -- ROUGE -> BLEU
                        when "11"   => color_reg <= "10";  -- BLEU  -> VERT
                        when "10"   => color_reg <= "01";  -- VERT  -> ROUGE
                        when others => color_reg <= "01";
                    end case;

                    update_reg <= '1';

                else
                    blink_cnt <= blink_cnt + 1;
                end if;

            end if;

        end if;
    end process;

    color_code_o <= color_reg;
    update_o     <= update_reg;

end rtl;
