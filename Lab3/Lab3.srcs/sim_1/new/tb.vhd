----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/13/2025 11:44:15 AM
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
USE ieee.numeric_std.ALL;

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
    SIGNAL clk_i    : STD_LOGIC := '0';
    SIGNAL btn_i    : STD_LOGIC_VECTOR(3 DOWNTO 0) := (others => '0');
    SIGNAL sw_i     : STD_LOGIC_VECTOR(7 DOWNTO 0) := (others => '0');
    SIGNAL digit_o  : STD_LOGIC_VECTOR(31 DOWNTO 0);
    
    CONSTANT clk_period : TIME := 10 ns;

begin
    
    uut: ENTITY work.memencoder PORT MAP (
        clk_i   => clk_i,
        btn_i   => btn_i,
        sw_i    => sw_i,
        digit_o => digit_o
    );

    clk_process: PROCESS
    BEGIN
        WHILE NOW < 50 ms LOOP
            clk_i <= '0';
            WAIT FOR clk_period / 2;
            clk_i <= '1';
            WAIT FOR clk_period / 2;
        END LOOP;
        WAIT;
    END PROCESS;
    
    stim_proc: PROCESS
    BEGIN
        sw_i(7 downto 4) <= "1010"; 
        WAIT FOR 5 ms;
        
        FOR i IN 0 TO 3 LOOP
            btn_i(i) <= '1';
            WAIT FOR 1 ms;
            btn_i(i) <= '0';
            WAIT FOR 1 ms;
            sw_i(3 DOWNTO 0) <= std_logic_vector(to_unsigned((i+5) mod 16, 4));
            WAIT FOR 1 ms;
        END LOOP;
        
        WAIT FOR 5 ms;
        sw_i(7 downto 4) <= "0101"; 
        WAIT FOR 5 ms;
        sw_i(7 downto 4) <= "1100"; 
        
        WAIT;
    END PROCESS;

end Behavioral;
