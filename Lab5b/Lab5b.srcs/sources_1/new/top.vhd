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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


entity top is
    Port ( clk_i : in STD_LOGIC;  -- 100 MHz clock input
           sw_i : in STD_LOGIC_VECTOR(7 downto 0);  -- Switches for frequency and phase settings
           btn_i : in STD_LOGIC_VECTOR(3 downto 0);  -- Buttons for adjusting frequencies and phase
           red_o : out STD_LOGIC;  -- VGA red channel output
           green_o : out STD_LOGIC;  -- VGA green channel output
           blue_o : out STD_LOGIC;  -- VGA blue channel output
           hsync_o : out STD_LOGIC;  -- VGA horizontal sync
           vsync_o : out STD_LOGIC   -- VGA vertical sync
           );
end top;

architecture Behavioral of top is

    -- DDS components for generating sine waves for X and Y
    signal clk_100MHz : STD_LOGIC;
    signal freq_x     : STD_LOGIC_VECTOR(7 downto 0);
    signal freq_y     : STD_LOGIC_VECTOR(7 downto 0);
    signal phase_x    : STD_LOGIC_VECTOR(7 downto 0);
    signal phase_y    : STD_LOGIC_VECTOR(7 downto 0);
    signal sine_x     : STD_LOGIC_VECTOR(15 downto 0);
    signal sine_y     : STD_LOGIC_VECTOR(15 downto 0);
    
    -- VGA sync signals
    signal hsync      : STD_LOGIC;
    signal vsync      : STD_LOGIC;
    signal pixel_x    : INTEGER range 0 to 639;  -- Horizontal pixel position
    signal pixel_y    : INTEGER range 0 to 479;  -- Vertical pixel position
    signal pixel_data : STD_LOGIC;
    
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

    X_dds: singen
        Port map ( 
            aclk          => clk_i,
            aclken        => '1',
            aresetn       => '1',  -- Active low reset signal
            s_axis_config_tvalid => '1',
            s_axis_config_tdata  => (others => '0'),  -- Frequency setting
            s_axis_config_tlast  => '0',
            m_axis_data_tvalid  => open,
            m_axis_data_tdata   => sine_x
        );

    -- Instantiate DDS for Y channel (sine wave generation)
    Y_dds: singen
        Port map ( 
            aclk          => clk_i,
            aclken        => '1',
            aresetn       => '1',
            s_axis_config_tvalid => '1',
            s_axis_config_tdata  => (others => '0'),  -- Frequency setting
            s_axis_config_tlast  => '0',
            m_axis_data_tvalid  => open,
            m_axis_data_tdata   => sine_y
        );
        
    vga_controller: process(clk_i)
    begin
        -- VGA controller logic here (pixel_x, pixel_y, hsync, vsync)
    end process;
        
    PROCESS (clk_i)
BEGIN
  IF rising_edge(clk_i) THEN
    IF (clean_screen = '1') THEN
      -- Resetowanie pami?ci wideo (czy?ci ekran)
      wea <= '0';
    ELSE
      -- Zapis pikseli do pami?ci
      -- Przyk?ad zapisania bia?ego piksela
      IF (wsp??rz?dne_w_figurze_Lissajous) THEN
        dina <= "1"; -- warto?? bia?a
        wea <= '1'; -- sygna? zapisu
        addra <= address_piksela; -- adres pami?ci, kt?ry odpowiada wsp??rz?dnym piksela
      ELSE
        dina <= "0"; -- warto?? czarna
        wea <= '1'; -- sygna? zapisu
        addra <= address_piksela; -- adres pami?ci
      END IF;
    END IF;
  END IF;
END PROCESS;


end Behavioral;
