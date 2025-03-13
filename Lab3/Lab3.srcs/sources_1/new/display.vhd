----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/27/2025 12:56:12 PM
-- Design Name: 
-- Module Name: display - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity display is
    Port (
        clk_i      : in  STD_LOGIC;
        rst_i      : in  STD_LOGIC;
        digit_i    : in  STD_LOGIC_VECTOR(31 downto 0);
        led7_an_o  : out STD_LOGIC_VECTOR(3 downto 0);
        led7_seg_o : out STD_LOGIC_VECTOR(7 downto 0)
    );
end display;

architecture Behavioral of display is
    signal clk_div : INTEGER := 0;
    signal clk_reset : INTEGER := 10;
    signal anode_sel : INTEGER range 0 to 3 := 0;
    signal digit_out : STD_LOGIC_VECTOR(7 downto 0);
begin
    process(clk_i)
    begin
        if rising_edge(clk_i) then
            if clk_div = clk_reset then
                clk_div <= 0;
                anode_sel <= (anode_sel + 1) mod 4;
            else
                clk_div <= clk_div + 1;
            end if;
        end if;
    end process;

    process(anode_sel, digit_i)
    begin
        case anode_sel is
            when 0 => digit_out <= digit_i(7 downto 0);
            when 1 => digit_out <= digit_i(15 downto 8);
            when 2 => digit_out <= digit_i(23 downto 16);
            when 3 => digit_out <= digit_i(31 downto 24);
            when others => digit_out <= "00000000";
        end case;
    end process;

    led7_seg_o <= digit_out;
    led7_an_o  <= "0000" when rst_i = '1' else
                  "1110" when anode_sel = 0 else
                  "1101" when anode_sel = 1 else
                  "1011" when anode_sel = 2 else
                  "0111";
end Behavioral;
