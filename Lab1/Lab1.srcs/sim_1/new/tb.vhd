----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/26/2025 08:40:13 PM
-- Design Name: 
-- Module Name: tb - Behavioral
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

entity tb is
--  Port ( );
end tb;

architecture Behavioral of tb is
    component top
        Port ( sw_i       : in  STD_LOGIC_VECTOR(7 downto 0);
               led7_an_o  : out STD_LOGIC_VECTOR(3 downto 0);
               led7_seg_o : out STD_LOGIC_VECTOR(7 downto 0));
    end component;
    signal sw_i_tb       : STD_LOGIC_VECTOR(7 downto 0);
    signal led7_an_tb    : STD_LOGIC_VECTOR(3 downto 0);
    signal led7_seg_tb   : STD_LOGIC_VECTOR(7 downto 0);
begin
    uut: top port map (
        sw_i       => sw_i_tb,
        led7_an_o  => led7_an_tb,
        led7_seg_o => led7_seg_tb
    );

    process
    begin
        sw_i_tb <= "00000000";
        wait for 100 ms;
        for i in 0 to 7 loop
            sw_i_tb(i) <= '1';
            wait for 100 ms;
        end loop;
        wait;
    end process;
end Behavioral;
