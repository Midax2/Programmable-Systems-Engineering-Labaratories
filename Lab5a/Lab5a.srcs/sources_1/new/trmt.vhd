----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    
-- Design Name: 
-- Module Name:    trmt - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: UART Transmission Module
--
-- Dependencies: None
--
-- Revision: 
-- Revision 0.02 - Improved Code Structure
-- Additional Comments: Refactored for clarity and efficiency
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity trmt is
    Port (
        clk_i            : in  STD_LOGIC;
        data_i           : in  STD_LOGIC_VECTOR(7 downto 0);
        TXD_enable_i     : in  STD_LOGIC;  -- Start transmission
        TXD_is_working_o : out STD_LOGIC;  -- Transmission in progress
        TXD_o            : out STD_LOGIC   -- Serial data output
    );
end trmt;

architecture Behavioral of trmt is

    type state_type is (standby, sending);  
	signal state : state_type := standby;
	
	signal sending_bit : STD_LOGIC := '1';
	signal bits_transmitted : Integer := 0;
	
	signal counter : Integer := 0;
	
	signal is_working : STD_LOGIC := '0';


begin

    TXD_o            <= sending_bit;
    TXD_is_working_o <= is_working;

    process (clk_i)
    begin
        if rising_edge(clk_i) then
            case state is
			when standby =>
				if TXD_enable_i = '1' and is_working = '0' then
					
					is_working <= '1';			
					sending_bit <= '0';
					counter <= 0;
					bits_transmitted <= 0;
					
					state <= sending;
					
				elsif counter < 10418 then
					counter <= counter + 1;
				else 
					is_working <= '0';
				end if;
			
			when sending =>
				if counter < 5209 then
					counter <= counter + 1;
				elsif bits_transmitted < 8 then
					counter <= 0;
					sending_bit <= data_i(bits_transmitted);
					bits_transmitted <= bits_transmitted + 1;
				else 
					
					sending_bit <= '1';
					counter <= 0;
					
					state <= standby;
					
				end if;
		end case;

        end if;
    end process;
end Behavioral;
