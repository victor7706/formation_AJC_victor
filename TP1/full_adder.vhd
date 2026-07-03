library ieee;
use ieee.std_logic_1164.all;


entity full_adder is

	Port ( 
		--Exemple d'entrees
		a 	   : in std_logic;
		b 	   : in std_logic;
		Cin    : in std_logic;

		--Exemple de sorties
		S  	   : out std_logic;
		Cout   : out std_logic
	);

end full_adder;

 

architecture behavior of full_adder is

signal X : std_logic;
signal Y1 : std_logic;
signal Y2 : std_logic;

begin
    X <= A XOR B;
    S <= X XOR Cin;
    Y1 <= A AND B;
    Y2 <= X AND Cin;
    Cout <= Y1 OR Y2;


end behavior;

