library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity counter_unit is
    port ( 
		clk			: in std_logic; 
        resetn		: in std_logic; 
        XX			: out XX 
     );
end counter_unit;

architecture behavioral of counter_unit is
	
	--Declaration des signaux internes
    constant XX : positive := XX;
	signal XX 	: XX;
	
	begin

		--Partie sequentielle
		process(clk,resetn)
		begin
			if(resetn = '0') then 
			
			else if(rising_edge(clk)) then
			
			end if;
		end process;
		
		--Partie combinatoire
		XX <= XX when XX
				else XX;
						

end behavioral;