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
        rst_i            : in  STD_LOGIC;
        data_i           : in  STD_LOGIC_VECTOR(7 downto 0);
        TXD_enable_i     : in  STD_LOGIC;  -- Start transmission
        TXD_is_working_o : out STD_LOGIC;  -- Transmission in progress
        TXD_o            : out STD_LOGIC   -- Serial data output
    );
end trmt;

architecture Behavioral of trmt is

    type state_type is (IDLE, START_BIT, DATA_BITS, STOP_BIT);
    signal state        : state_type := IDLE;
    signal bit_counter  : integer range 0 to 9 := 0;
    signal baud_counter : integer := 0;
    signal tx_shift_reg : STD_LOGIC_VECTOR(9 downto 0) := (others => '1');
    signal is_sending  : STD_LOGIC := '0';

    constant BAUD_DIVISOR : integer := 5208;  -- Adjust based on clock frequency

begin

    TXD_o            <= tx_shift_reg(0);
    TXD_is_working_o <= is_sending;

    process (clk_i, rst_i)
    begin
        if rst_i = '1' then
            state        <= IDLE;
            tx_shift_reg <= (others => '1');
            bit_counter  <= 0;
            baud_counter <= 0;
            is_sending   <= '0';
        elsif rising_edge(clk_i) then
            case state is
                when IDLE =>
                    if TXD_enable_i = '1' then
                        tx_shift_reg <= '1' & data_i & '0';  -- Start + Data + Stop bit
                        bit_counter  <= 0;
                        baud_counter <= 0;
                        is_sending   <= '1';
                        state        <= START_BIT;
                    end if;

                when START_BIT | DATA_BITS | STOP_BIT =>
                    if baud_counter < BAUD_DIVISOR then
                        baud_counter <= baud_counter + 1;
                    else
                        baud_counter <= 0;
                        tx_shift_reg <= '1' & tx_shift_reg(9 downto 1);
                        bit_counter  <= bit_counter + 1;

                        if bit_counter = 9 then
                            state      <= IDLE;
                            is_sending <= '0';
                        end if;
                    end if;
            end case;
        end if;
    end process;

end Behavioral;
