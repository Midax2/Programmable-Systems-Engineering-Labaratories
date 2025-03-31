-- Display Controller Module
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Display_Controller is
    Port (
        clk_i : in STD_LOGIC;              
        rst_i : in STD_LOGIC;              
        data_i : in STD_LOGIC_VECTOR(7 downto 0); 
        led7_an_o : out STD_LOGIC_VECTOR(3 downto 0); 
        led7_seg_o : out STD_LOGIC_VECTOR(7 downto 0) 
    );
end Display_Controller;

architecture Behavioral of Display_Controller is
    type seg_array is array (0 to 15) of STD_LOGIC_VECTOR(7 downto 0);
    constant SEGMENTS : seg_array := (
        "00000011", -- 0
        "10011111", -- 1
        "00100101", -- 2
        "00001101", -- 3
        "10011001", -- 4
        "01001001", -- 5
        "01000001", -- 6
        "00011111", -- 7
        "00000001", -- 8
        "00001001", -- 9
        "00010001", -- A
        "11000001", -- B
        "01100011", -- C
        "10000101", -- D
        "01100001", -- E
        "01110001"  -- F
    );

   
    signal hex_digit : STD_LOGIC_VECTOR(3 downto 0);
    signal digit_index : integer range 0 to 1 := 0;
    signal clk_div : integer := 0;
    constant CLK_DIV_MAX : integer := 100_000;

begin
    process(clk_i)
    begin
        if rising_edge(clk_i) then
            if rst_i = '1' then
                clk_div <= 0;
                digit_index <= 0;
            elsif clk_div = CLK_DIV_MAX then
                clk_div <= 0;
                digit_index <= 1 - digit_index;
            else
                clk_div <= clk_div + 1;
            end if;
        end if;
    end process;

    
    process(digit_index, data_i)
    begin
        if digit_index = 0 then
            hex_digit <= data_i(3 downto 0);
            led7_an_o <= "1110";            
        else
            hex_digit <= data_i(7 downto 4);
            led7_an_o <= "1101";            
        end if;
        led7_seg_o <= SEGMENTS(to_integer(unsigned(hex_digit)));
    end process;

end Behavioral;