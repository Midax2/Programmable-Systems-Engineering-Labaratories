----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/23/2025 07:54:20 PM
-- Design Name: 
-- Module Name: top - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


entity top is
    Port (
        clk_i      : in  STD_LOGIC;
        sw_i       : in  STD_LOGIC_VECTOR(7 downto 0);
        btn_i      : in  STD_LOGIC_VECTOR(3 downto 0);
        hsync_o    : out STD_LOGIC;
        vsync_o    : out STD_LOGIC;
        red_o      : out STD_LOGIC_VECTOR(3 downto 0);
        green_o    : out STD_LOGIC_VECTOR(3 downto 0);
        blue_o     : out STD_LOGIC_VECTOR(3 downto 0)
    );
end top;

architecture Behavioral of top is

    signal x_freq, y_freq, y_phase : STD_LOGIC_VECTOR(7 downto 0);
    signal sin_x, sin_y : STD_LOGIC_VECTOR(10 downto 0);
    signal pixel_x, pixel_y : INTEGER range 0 to 383;
    signal write_enable : STD_LOGIC_VECTOR(0 downto 0) := "0";
    signal write_address : STD_LOGIC_VECTOR(17 downto 0);
    signal write_data : STD_LOGIC_VECTOR(0 downto 0) := "1";
    signal config_tdata_signal_x : std_logic_vector(31 downto 0);
    signal config_tdata_signal_y : std_logic_vector(31 downto 0);
    
    component video_mem is
        Port (
            clka : in STD_LOGIC;
            wea : in STD_LOGIC_VECTOR(0 downto 0);
            addra : in STD_LOGIC_VECTOR(17 downto 0);
            dina : in STD_LOGIC_VECTOR(0 downto 0);
            clkb : in STD_LOGIC;
            addrb : in STD_LOGIC_VECTOR(17 downto 0);
            doutb : out STD_LOGIC_VECTOR(0 downto 0)
        );
    end component;
    
    component singen is
        Port (
            aclk : in STD_LOGIC;
            aclken : in STD_LOGIC;
            aresetn : in STD_LOGIC;
            s_axis_config_tvalid : in STD_LOGIC;
            s_axis_config_tdata : in STD_LOGIC_VECTOR(31 downto 0);
            s_axis_config_tlast : in STD_LOGIC;
            m_axis_data_tvalid : out STD_LOGIC;
            m_axis_data_tdata : out STD_LOGIC_VECTOR(15 downto 0);
            event_s_config_tlast_missing : out STD_LOGIC;
            event_s_config_tlast_unexpected : out STD_LOGIC
        );
    end component;

begin
process (clk_i)
    begin
        if rising_edge(clk_i) then
            if btn_i(3) = '1' then
                x_freq <= sw_i;
            elsif btn_i(2) = '1' then
                y_freq <= sw_i;
            elsif btn_i(1) = '1' then
                y_phase <= sw_i;
            elsif btn_i(0) = '1' then
                write_enable <= "0";
            end if;
        end if;
    end process;
    config_tdata_signal_x <= x"0000" & x_freq;
    config_tdata_signal_y <= y_phase & y_freq;
    -- DDS Generator
    DDS_X : singen
        port map (
            aclk => clk_i,
            aclken => '1',
            aresetn => '1',
            s_axis_config_tvalid => '1',
            s_axis_config_tdata => config_tdata_signal_x,
            s_axis_config_tlast => '1',
            m_axis_data_tvalid => open,
            m_axis_data_tdata => sin_x,
            event_s_config_tlast_missing => open,
            event_s_config_tlast_unexpected => open
        );

    DDS_Y : singen
        port map (
            aclk => clk_i,
            aclken => '1',
            aresetn => '1',
            s_axis_config_tvalid => '1',
            s_axis_config_tdata => config_tdata_signal_y,
            s_axis_config_tlast => '1',
            m_axis_data_tvalid => open,
            m_axis_data_tdata => sin_y,
            event_s_config_tlast_missing => open,
            event_s_config_tlast_unexpected => open
        );
    
    process (clk_i)
    begin
        if rising_edge(clk_i) then
            pixel_x <= (to_integer(unsigned(sin_x)) + 1024) * 192 / 1024;
            pixel_y <= (to_integer(unsigned(sin_y)) + 1024) * 192 / 1024;
            write_address <= std_logic_vector(to_unsigned(pixel_y * 384 + pixel_x, 18));
            write_enable <= "1";
        end if;
    end process;
    
    -- VGA Output
    VGA_VIDEO : video_mem
        port map (
            clka => clk_i,
            wea  => write_enable,
            addra => write_address,
            dina  => write_data,
            clkb  => clk_i,
            addrb => write_address,
            doutb => open
        );
    
    -- Synchronizacja VGA i rysowanie obrazu
    process (clk_i)
    begin
        if rising_edge(clk_i) then
            hsync_o <= '0';
            vsync_o <= '0';
            red_o   <= (others => write_enable(0));
            green_o <= (others => write_enable(0));
            blue_o  <= (others => write_enable(0));
        end if;
    end process;
end Behavioral;
