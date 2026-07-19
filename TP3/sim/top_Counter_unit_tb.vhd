library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_Counter_unit_tb is
end top_Counter_unit_tb;

architecture tb of top_Counter_unit_tb is

    -- component declaration
    component top_Counter_unit
    generic (
        MAX_COUNT : unsigned(27 downto 0) := "0000000000000000000000000111" --7dec
    );
    
    Port ( clk : in STD_LOGIC;
           resetn : in STD_LOGIC;       
           end_counter : out STD_LOGIC
           );
end component;
    
    -- signals
    constant MAX_COUNT  : unsigned(27 downto 0) := "0000000000000000000000000111"; --7dec
    signal clk          : std_logic := '0';
    signal resetn         : std_logic := '0';
    signal end_counter  : std_logic:= '0';
    
begin

    -- DUT instantiation
    uut: top_Counter_unit
            generic map (
            MAX_COUNT => MAX_COUNT
        )
        port map (
            clk          => clk,
            resetn         => resetn,
            end_counter  => end_counter
        );

 
    clk <= not clk after 5 ns;



    stim_proc : process
    begin
        resetn <= '1';
        wait for 30 ns;

        resetn <= '0';
       
        wait for 900ns;
        
        resetn <= '0';
        wait for 200 ns;
        
    end process;
    
    

end tb;
