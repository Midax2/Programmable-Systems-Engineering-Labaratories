----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/27/2025 01:01:00 PM
-- Design Name: 
-- Module Name: memencoder - Behavioral
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

entity memencoder is
    Port (
        clk_i    : in  STD_LOGIC;
        btn_i    : in  STD_LOGIC_VECTOR (3 downto 0);
        sw_i     : in  STD_LOGIC_VECTOR (7 downto 0);
        digit_o  : out STD_LOGIC_VECTOR(31 downto 0)
    );
end memencoder;

architecture Behavioral of memencoder is
    signal digit_reg : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

    function hex_to_7seg(hex: STD_LOGIC_VECTOR(3 downto 0)) return STD_LOGIC_VECTOR is
    begin
        case hex is
            when "0000" => return "11000000"; -- 0
            when "0001" => return "11111001"; -- 1
            when "0010" => return "10100100"; -- 2
            when "0011" => return "10110000"; -- 3
            when "0100" => return "10011001"; -- 4
            when "0101" => return "10010010"; -- 5
            when "0110" => return "10000010"; -- 6
            when "0111" => return "11111000"; -- 7
            when "1000" => return "10000000"; -- 8
            when "1001" => return "10010000"; -- 9
            when "1010" => return "10001000"; -- A
            when "1011" => return "10000011"; -- B
            when "1100" => return "11000110"; -- C
            when "1101" => return "10100001"; -- D
            when "1110" => return "10000110"; -- E
            when "1111" => return "10001110"; -- F
            when others => return "11111111"; -- Blank
        end case;
    end function;
begin
    process(clk_i)
    begin
        if rising_edge(clk_i) then
            if btn_i(0) = '1' then digit_reg(7 downto 0)   <= hex_to_7seg(sw_i(3 downto 0)); end if;
            if btn_i(1) = '1' then digit_reg(15 downto 8)  <= hex_to_7seg(sw_i(3 downto 0)); end if;
            if btn_i(2) = '1' then digit_reg(23 downto 16) <= hex_to_7seg(sw_i(3 downto 0)); end if;
            if btn_i(3) = '1' then digit_reg(31 downto 24) <= hex_to_7seg(sw_i(3 downto 0)); end if;

            digit_reg(7)  <= sw_i(4);
            digit_reg(15) <= sw_i(5);
            digit_reg(23) <= sw_i(6);
            digit_reg(31) <= sw_i(7);
        end if;
    end process;

    digit_o <= digit_reg;
end Behavioral;
