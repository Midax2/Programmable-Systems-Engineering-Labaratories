----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    
-- Design Name: 
-- Module Name:    top - Structural 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Top-level module integrating receiver, transmitter, display, FIFO, and ROM.
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.02 - Improved Code Structure
-- Additional Comments: Refactored for clarity and efficiency
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;



entity top is
    Port (
        clk_i       : in  STD_LOGIC;
        RXD_i       : in  STD_LOGIC;
        TXD_o       : out STD_LOGIC;
        ld0         : out STD_LOGIC;
        led7_an_o   : out STD_LOGIC_VECTOR (3 downto 0);
        led7_seg_o  : out STD_LOGIC_VECTOR (7 downto 0)
    );
end top;

architecture Structural of top is
    -- Component declarations
    component char_mem
        Port (
            clka  : in  STD_LOGIC;
            addra : in  STD_LOGIC_VECTOR(11 downto 0);
            douta : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    component fifo_mem
        Port (
            clk     : in  STD_LOGIC;
            din     : in  STD_LOGIC_VECTOR(7 downto 0);
            wr_en   : in  STD_LOGIC;
            rd_en   : in  STD_LOGIC;
            dout    : out STD_LOGIC_VECTOR(7 downto 0);
            full    : out STD_LOGIC;
            empty   : out STD_LOGIC
        );
    end component;

    component trmt
        Port (
            clk_i            : in  STD_LOGIC;
            data_i           : in  STD_LOGIC_VECTOR(7 downto 0);
            TXD_enable_i     : in  STD_LOGIC;
            TXD_is_working_o : out STD_LOGIC;
            TXD_o            : out STD_LOGIC
        );
    end component;

    component RS232_Receiver
        Port (
            clk_i    : in  STD_LOGIC;
            RXD_i    : in  STD_LOGIC;
            data_o   : out STD_LOGIC_VECTOR(7 downto 0);
            data_ready_o: out STD_LOGIC
        );
    end component;

    component Display_Controller
        Port (
            clk_i       : in  STD_LOGIC;
            data_i     : in  STD_LOGIC_VECTOR (7 downto 0);
            led7_an_o   : out STD_LOGIC_VECTOR (3 downto 0);
            led7_seg_o  : out STD_LOGIC_VECTOR (7 downto 0)
        );
    end component;

   constant ROW_MAX : Integer := 6;
	
	-- RXD/TXD signal
	
	signal t_digit_o : STD_LOGIC_VECTOR(31 downto 0);
	
	-- RXD signals
	
	signal t_data_RXD : STD_LOGIC_VECTOR(7 downto 0) := X"FF";
	signal t_RXD_fin_o : STD_LOGIC := '0';
	
	-- TXD signals
	
	signal TXD_enable : std_logic := '0';
	signal TXD_working : std_logic;
	signal t_data_TXD : STD_LOGIC_VECTOR(7 downto 0) := X"FF";
	
	-- FIFO signals
	
	signal rd_enable : std_logic := '0';
	signal wr_enable : std_logic := '0';
	signal fifo_in :std_logic_vector (7 downto 0);
	signal fifo_out : std_logic_vector (7 downto 0);
	
	-- ROM signals
	
	signal mem_addr : std_logic_vector (11 downto 0);
	signal mem_out : std_logic_vector (7 downto 0);

	-- bufor dla TXD (z linia do wyslania) 

	type my_array is array (ROW_MAX - 1 downto 0) of std_logic_vector(7 downto 0);
	signal rtt : my_array;
	SHARED variable rtt_cnt : Integer := 0;

	-- stany wysylania
	
	signal ascii_code : STD_LOGIC_VECTOR(7 downto 0) := X"00";
	
	SHARED variable ascii_num : Integer := 0;
	SHARED variable ascii_row : Integer := 0;
	SHARED variable ascii_bit : Integer := 0;
	
	SHARED variable rows_received : Integer := 0;

	-- stany transmitera
	type t_state is (standby, transmit, dequeue);
	signal TXD_actual_state : t_state := standby;
	signal TXD_state : t_state;
	
	signal empty : STD_LOGIC := '0';

begin
    -- Component instantiations
    RXD  : RS232_Receiver port map (clk_i, RXD_i, t_data_RXD, t_RXD_fin_o);
    TXD  : trmt port map (clk_i, t_data_TXD, TXD_enable, TXD_working, TXD_o);
    LCD  : Display_Controller port map (clk_i, t_data_RXD, led7_an_o, led7_seg_o);
    ROM  : char_mem port map (clk_i, mem_addr, mem_out);
    FIFO : fifo_mem port map (clk_i, fifo_in, wr_enable, rd_enable, fifo_out, ld0, empty);

    TXD_actual_state <= TXD_state;
	
	ascii_code <= rtt(ascii_num)(7 downto 0) when ( CONV_INTEGER(rtt(ascii_num)(7 downto 0)) >= 32 )else X"2A";
	
	mem_addr(11 downto 4) <= rtt(ascii_num)(7 downto 0);
	mem_addr(3 downto 0) <= CONV_STD_LOGIC_VECTOR(ascii_row, 4);


    process (clk_i)
    begin
        if rising_edge(clk_i) then
			
			wr_enable <= '0';
			rd_enable <= '0';
			TXD_enable <= '0';
					
			if t_RXD_fin_o = '1' and wr_enable = '0' then
				wr_enable <= '1';
				fifo_in <= t_data_RXD;
				rows_received := rows_received + 1;
			else 
			
			case TXD_actual_state is
				when standby =>
					if rows_received > ROW_MAX - 1  then
						
						rd_enable <= '1';
						rtt_cnt := 0;
						
						TXD_state <= dequeue;
					
					end if;
				when dequeue =>
					
						rtt(rtt_cnt)(7 downto 0) <= fifo_out;
						rtt_cnt := rtt_cnt + 1;
						
						if rtt_cnt = ROW_MAX then
						
							ascii_num := 0;
							ascii_row := 0;
							ascii_bit := 0;
						
							TXD_state <= transmit;
						
						else 
							rd_enable <= '1';
						end if;
					
				
					
				when transmit =>
					if ascii_row = 16 then -- wypisal wszystkie wiersze
					
						rows_received := rows_received - ROW_MAX;
						
						TXD_state <= standby;
					
					elsif TXD_working = '0' and TXD_enable = '0' then
						if ascii_num = ROW_MAX then -- jesli wypisal ostatni znak
						
							if t_data_TXD /= X"0A" then -- to jesli nie bylo CR
								
								TXD_enable <= '1';
								t_data_TXD <= X"0A";
								
							else 
							
								TXD_enable <= '1';
								t_data_TXD <= X"0D";
								ascii_num := 0;
								ascii_row := ascii_row + 1;
							
							end if;
							
						else
							
							TXD_enable <= '1';
							
							case mem_out(7 - ascii_bit) is
								when '1' => t_data_TXD <= ascii_code;
								when '0' => t_data_TXD <= X"20";
								when others => t_data_TXD <= X"00";
							end case;
							
							ascii_bit := ascii_bit + 1;
							
							if ascii_bit = 8 then
								ascii_bit := 0;
								ascii_num := ascii_num + 1;
							end if;
							
						end if;
					end if;

			end case;
			
			end if;
		
		end if;

    end process;
end Structural;
