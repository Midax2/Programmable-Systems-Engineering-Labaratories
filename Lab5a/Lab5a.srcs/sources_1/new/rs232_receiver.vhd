-- RS232 Receiver Module
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RS232_Receiver is
    Port (
        clk_i : in STD_LOGIC;              -- 100 MHz clock
        RXD_i : in STD_LOGIC;              -- RS232 input
        data_o : out STD_LOGIC_VECTOR(7 downto 0); -- Received data output
        data_ready_o : out STD_LOGIC       -- Data ready signal
    );
end RS232_Receiver;

architecture Behavioral of RS232_Receiver is
    constant BAUD_RATE : integer := 9600;
    constant CLK_FREQ : integer := 100_000_000;
    constant CLKS_PER_BIT : integer := CLK_FREQ / BAUD_RATE;

    signal clk_count : integer range 0 to CLKS_PER_BIT - 1 := 0;
    signal bit_index : integer range 0 to 9 := 0; -- 1 start, 8 data, 1 stop
    signal rx_shift : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal receiving : STD_LOGIC := '0';
    signal data_ready : STD_LOGIC := '0';
    signal RXD_TEMP : STD_LOGIC;

begin
    process(clk_i)
    begin
        if rising_edge(clk_i) then
            RXD_TEMP <= RXD_i;
            if receiving = '0' and RXD_TEMP = '0' then
                receiving <= '1';
                clk_count <= CLKS_PER_BIT / 2; 
                bit_index <= 0;
            elsif receiving = '1' then
                if clk_count = 0 then
                    clk_count <= CLKS_PER_BIT - 1;
                    if bit_index = 9 then
                        receiving <= '0';
                        data_ready <= '1';
                        data_o <= rx_shift;
                    else
                        bit_index <= bit_index + 1;
                        if bit_index > 0 and bit_index < 9 then
                            rx_shift(bit_index - 1) <= RXD_TEMP;
                        end if;
                    end if;
                else
                    clk_count <= clk_count - 1;
                end if;
            end if;
        end if;
    end process;

    data_ready_o <= data_ready;

end Behavioral;