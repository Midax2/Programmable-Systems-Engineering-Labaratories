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

entity top is
    Port (
        clk_i       : in  STD_LOGIC;
        rst_i       : in  STD_LOGIC;
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
            rst     : in  STD_LOGIC;
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
            rst_i            : in  STD_LOGIC;
            data_i           : in  STD_LOGIC_VECTOR(7 downto 0);
            TXD_enable_i     : in  STD_LOGIC;
            TXD_is_working_o : out STD_LOGIC;
            TXD_o            : out STD_LOGIC
        );
    end component;

    component RS232_Receiver
        Port (
            clk_i    : in  STD_LOGIC;
            rst_i    : in  STD_LOGIC;
            RXD_i    : in  STD_LOGIC;
            data_o   : out STD_LOGIC_VECTOR(7 downto 0);
            data_ready_o: out STD_LOGIC
        );
    end component;

    component Display_Controller
        Port (
            clk_i       : in  STD_LOGIC;
            rst_i       : in  STD_LOGIC;
            digit_i     : in  STD_LOGIC_VECTOR (7 downto 0);
            led7_an_o   : out STD_LOGIC_VECTOR (3 downto 0);
            led7_seg_o  : out STD_LOGIC_VECTOR (7 downto 0)
        );
    end component;

    -- Constants
    constant ROW_MAX : integer := 6;

    -- Signal Declarations
    signal t_digit_o      : STD_LOGIC_VECTOR(31 downto 0);
    signal t_data_RXD     : STD_LOGIC_VECTOR(7 downto 0) := X"FF";
    signal t_RXD_fin_o    : STD_LOGIC := '0';
    signal TXD_enable     : STD_LOGIC := '0';
    signal TXD_working    : STD_LOGIC;
    signal t_data_TXD     : STD_LOGIC_VECTOR(7 downto 0) := X"FF";
    signal rd_enable      : STD_LOGIC := '0';
    signal wr_enable      : STD_LOGIC := '0';
    signal fifo_in        : STD_LOGIC_VECTOR (7 downto 0);
    signal fifo_out       : STD_LOGIC_VECTOR (7 downto 0);
    signal mem_addr       : STD_LOGIC_VECTOR (11 downto 0);
    signal mem_out        : STD_LOGIC_VECTOR (7 downto 0);

    type my_array is array (ROW_MAX - 1 downto 0) of std_logic_vector(7 downto 0);
    signal rtt : my_array;
    shared variable rtt_cnt : integer := 0;
    signal ascii_code : STD_LOGIC_VECTOR(7 downto 0) := X"00";
    shared variable ascii_num, ascii_row, ascii_bit, rows_received : integer := 0;

    type t_state is (standby, transmit, dequeue);
    signal TXD_actual_state, TXD_state : t_state := standby;
    signal empty : STD_LOGIC := '0';

begin
    -- Component instantiations
    RXD  : RS232_Receiver port map (clk_i, rst_i, RXD_i, t_data_RXD, t_RXD_fin_o);
    TXD  : trmt port map (clk_i, rst_i, t_data_TXD, TXD_enable, TXD_working, TXD_o);
    LCD  : Display_Controller port map (clk_i, rst_i, t_data_RXD, led7_an_o, led7_seg_o);
    ROM  : char_mem port map (clk_i, mem_addr, mem_out);
    FIFO : fifo_mem port map (clk_i, rst_i, fifo_in, wr_enable, rd_enable, fifo_out, ld0, empty);

    TXD_actual_state <= TXD_state;

    ascii_code <=
        rtt(ascii_num)(7 downto 0) when (TO_INTEGER(unsigned(rtt(ascii_num)(7 downto 0))) >= 32)
        else X"2A";

    mem_addr(11 downto 4) <= rtt(ascii_num)(7 downto 0);
    mem_addr(3 downto 0)  <= STD_LOGIC_VECTOR(to_unsigned(ascii_row, 4));

    -- Main process
    process (clk_i, rst_i)
    begin
        if rst_i = '1' then
            TXD_enable <= '0';
            TXD_state  <= standby;
            wr_enable  <= '0';
            rd_enable  <= '0';
        elsif rising_edge(clk_i) then
            wr_enable <= '0';
            rd_enable <= '0';
            TXD_enable <= '0';
            if t_RXD_fin_o = '1' then
                wr_enable <= '1';
                fifo_in <= t_data_RXD;
                rows_received := rows_received + 1;
            end if;
            -- State machine logic for transmission (simplified)
        end if;
    end process;
end Structural;
