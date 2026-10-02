----------------------------------------------------------------------------------
-- Company: Digilent (base) / Adapted for Cora Z7-07S / SoCora project
-- 640x480@60Hz, real image display via DMA + AXI4-Stream FIFO
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity top is
    Port ( VGA_HS_O : out  STD_LOGIC;
           VGA_VS_O : out  STD_LOGIC;
           VGA_R : out  STD_LOGIC_VECTOR (3 downto 0);
           VGA_B : out  STD_LOGIC_VECTOR (3 downto 0);
           VGA_G : out  STD_LOGIC_VECTOR (3 downto 0);

           DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
           DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
           DDR_cas_n : inout STD_LOGIC;
           DDR_ck_n : inout STD_LOGIC;
           DDR_ck_p : inout STD_LOGIC;
           DDR_cke : inout STD_LOGIC;
           DDR_cs_n : inout STD_LOGIC;
           DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
           DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
           DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
           DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
           DDR_odt : inout STD_LOGIC;
           DDR_ras_n : inout STD_LOGIC;
           DDR_reset_n : inout STD_LOGIC;
           DDR_we_n : inout STD_LOGIC;
           FIXED_IO_ddr_vrn : inout STD_LOGIC;
           FIXED_IO_ddr_vrp : inout STD_LOGIC;
           FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
           FIXED_IO_ps_clk : inout STD_LOGIC;
           FIXED_IO_ps_porb : inout STD_LOGIC;
           FIXED_IO_ps_srstb : inout STD_LOGIC
         );
end top;

architecture Behavioral of top is

component design_1_wrapper is
  port (
    DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR_cas_n : inout STD_LOGIC;
    DDR_ck_n : inout STD_LOGIC;
    DDR_ck_p : inout STD_LOGIC;
    DDR_cke : inout STD_LOGIC;
    DDR_cs_n : inout STD_LOGIC;
    DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_odt : inout STD_LOGIC;
    DDR_ras_n : inout STD_LOGIC;
    DDR_reset_n : inout STD_LOGIC;
    DDR_we_n : inout STD_LOGIC;
    FIXED_IO_ddr_vrn : inout STD_LOGIC;
    FIXED_IO_ddr_vrp : inout STD_LOGIC;
    FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_ps_clk : inout STD_LOGIC;
    FIXED_IO_ps_porb : inout STD_LOGIC;
    FIXED_IO_ps_srstb : inout STD_LOGIC;
    M_AXIS_0_tdata : out STD_LOGIC_VECTOR ( 23 downto 0 );
    M_AXIS_0_tkeep : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M_AXIS_0_tlast : out STD_LOGIC;
    M_AXIS_0_tready : in STD_LOGIC;
    M_AXIS_0_tstrb : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M_AXIS_0_tuser : out STD_LOGIC_VECTOR ( 0 to 0 );
    M_AXIS_0_tvalid : out STD_LOGIC;
    led2_tri_o : out STD_LOGIC_VECTOR ( 2 downto 0 );
    led_tri_o : out STD_LOGIC_VECTOR ( 2 downto 0 );
    pixel_clk_out : out STD_LOGIC
  );
end component;

--***640x480@60Hz***--  Requires 25 MHz clock
constant FRAME_WIDTH : natural := 640;
constant FRAME_HEIGHT : natural := 480;

constant H_FP : natural := 16;
constant H_PW : natural := 96;
constant H_MAX : natural := 800;

constant V_FP : natural := 10;
constant V_PW : natural := 2;
constant V_MAX : natural := 525;

constant H_POL : std_logic := '0';
constant V_POL : std_logic := '0';

signal pxl_clk : std_logic;
signal pxl_clk_bufg : std_logic;
signal active : std_logic;

signal h_cntr_reg : std_logic_vector(11 downto 0) := (others =>'0');
signal v_cntr_reg : std_logic_vector(11 downto 0) := (others =>'0');

signal h_sync_reg : std_logic := not(H_POL);
signal v_sync_reg : std_logic := not(V_POL);

signal h_sync_dly_reg : std_logic := not(H_POL);
signal v_sync_dly_reg : std_logic :=  not(V_POL);

signal vga_red_reg : std_logic_vector(3 downto 0) := (others =>'0');
signal vga_green_reg : std_logic_vector(3 downto 0) := (others =>'0');
signal vga_blue_reg : std_logic_vector(3 downto 0) := (others =>'0');

signal vga_red : std_logic_vector(3 downto 0);
signal vga_green : std_logic_vector(3 downto 0);
signal vga_blue : std_logic_vector(3 downto 0);

-- Signaux AXI4-Stream venant de la FIFO (via design_1_wrapper)
signal m_axis_tdata  : std_logic_vector(23 downto 0);
signal m_axis_tkeep  : std_logic_vector(2 downto 0);
signal m_axis_tlast  : std_logic;
signal m_axis_tready : std_logic;
signal m_axis_tstrb  : std_logic_vector(2 downto 0);
signal m_axis_tuser  : std_logic_vector(0 to 0);
signal m_axis_tvalid : std_logic;

-- Resynchronisation "one-time sync, then lock" :
-- on ne recale les compteurs VGA sur le tout premier pixel de la
-- premiere trame qu'UNE SEULE FOIS, jamais ensuite, pour corriger
-- le decalage initial sans jamais perturber la frequence HSYNC/VSYNC.
signal sof_raw      : std_logic;
signal sof_raw_d    : std_logic := '0';
signal sof_pulse    : std_logic;
signal sof_accept   : std_logic;
signal frame_locked : std_logic := '0';

-- Conversion niveaux de gris (luminance) :
-- Y = (R + 2*G + B) / 4  -- poids 1-2-1, uniquement decalages/additions
signal r8       : std_logic_vector(7 downto 0);
signal g8       : std_logic_vector(7 downto 0);
signal b8       : std_logic_vector(7 downto 0);
signal luma_sum : std_logic_vector(9 downto 0);
signal vga_gray : std_logic_vector(3 downto 0);

begin

design_1_wrapper_inst : design_1_wrapper
  port map (
    DDR_addr => DDR_addr,
    DDR_ba => DDR_ba,
    DDR_cas_n => DDR_cas_n,
    DDR_ck_n => DDR_ck_n,
    DDR_ck_p => DDR_ck_p,
    DDR_cke => DDR_cke,
    DDR_cs_n => DDR_cs_n,
    DDR_dm => DDR_dm,
    DDR_dq => DDR_dq,
    DDR_dqs_n => DDR_dqs_n,
    DDR_dqs_p => DDR_dqs_p,
    DDR_odt => DDR_odt,
    DDR_ras_n => DDR_ras_n,
    DDR_reset_n => DDR_reset_n,
    DDR_we_n => DDR_we_n,
    FIXED_IO_ddr_vrn => FIXED_IO_ddr_vrn,
    FIXED_IO_ddr_vrp => FIXED_IO_ddr_vrp,
    FIXED_IO_mio => FIXED_IO_mio,
    FIXED_IO_ps_clk => FIXED_IO_ps_clk,
    FIXED_IO_ps_porb => FIXED_IO_ps_porb,
    FIXED_IO_ps_srstb => FIXED_IO_ps_srstb,
    M_AXIS_0_tdata => m_axis_tdata,
    M_AXIS_0_tkeep => m_axis_tkeep,
    M_AXIS_0_tlast => m_axis_tlast,
    M_AXIS_0_tready => m_axis_tready,
    M_AXIS_0_tstrb => m_axis_tstrb,
    M_AXIS_0_tuser => m_axis_tuser,
    M_AXIS_0_tvalid => m_axis_tvalid,
    led2_tri_o => open,
    led_tri_o => open,
    pixel_clk_out => pxl_clk
  );

BUFG_inst : BUFG
  port map (
    I => pxl_clk,
    O => pxl_clk_bufg
  );

  -- On ne consomme un nouveau pixel que pendant la zone active de l'image
  m_axis_tready <= active;

  -- Détecte l'acceptation reelle du tout premier pixel d'une trame (Start Of Frame)
  sof_raw <= '1' when (m_axis_tvalid = '1' and m_axis_tready = '1' and m_axis_tuser(0) = '1') else '0';

  process (pxl_clk_bufg)
  begin
    if (rising_edge(pxl_clk_bufg)) then
      sof_raw_d <= sof_raw;
    end if;
  end process;

  -- Detection de front : un seul cycle d'horloge a chaque nouveau SOF
  sof_pulse <= sof_raw and not sof_raw_d;

  -- Resynchronisation autorisee UNE SEULE FOIS, au tout premier SOF apres boot
  sof_accept <= sof_pulse and not frame_locked;

  process (pxl_clk_bufg)
  begin
    if (rising_edge(pxl_clk_bufg)) then
      if (sof_accept = '1') then
        frame_locked <= '1';
      end if;
    end if;
  end process;

  -- Composantes 8 bits venant du DMA (via FIFO)
  r8 <= m_axis_tdata(23 downto 16);
  g8 <= m_axis_tdata(15 downto 8);
  b8 <= m_axis_tdata(7  downto 0);

  -- Luminance approchee : Y = (R + 2*G + B) / 4 (poids 1-2-1, comme la ligne
  -- centrale du filtre gaussien) -- uniquement des decalages et additions
  luma_sum <= ("00" & r8) + ('0' & g8 & '0') + ("00" & b8);

  -- Image en niveaux de gris : meme valeur de luminance sur les 3 canaux
  vga_gray  <= luma_sum(9 downto 6) when active = '1' else (others => '0');
  vga_red   <= vga_gray;
  vga_green <= vga_gray;
  vga_blue  <= vga_gray;

  process (pxl_clk_bufg)
  begin
    if (rising_edge(pxl_clk_bufg)) then
      if (sof_accept = '1') then
        h_cntr_reg <= (others => '0');
      elsif (h_cntr_reg = (H_MAX - 1)) then
        h_cntr_reg <= (others =>'0');
      else
        h_cntr_reg <= h_cntr_reg + 1;
      end if;
    end if;
  end process;

  process (pxl_clk_bufg)
  begin
    if (rising_edge(pxl_clk_bufg)) then
      if (sof_accept = '1') then
        v_cntr_reg <= (others => '0');
      elsif ((h_cntr_reg = (H_MAX - 1)) and (v_cntr_reg = (V_MAX - 1))) then
        v_cntr_reg <= (others =>'0');
      elsif (h_cntr_reg = (H_MAX - 1)) then
        v_cntr_reg <= v_cntr_reg + 1;
      end if;
    end if;
  end process;

  process (pxl_clk_bufg)
  begin
    if (rising_edge(pxl_clk_bufg)) then
      if (h_cntr_reg >= (H_FP + FRAME_WIDTH - 1)) and (h_cntr_reg < (H_FP + FRAME_WIDTH + H_PW - 1)) then
        h_sync_reg <= H_POL;
      else h_sync_reg <= not(H_POL); end if;
    end if;
  end process;

  process (pxl_clk_bufg)
  begin
    if (rising_edge(pxl_clk_bufg)) then
      if (v_cntr_reg >= (V_FP + FRAME_HEIGHT - 1)) and (v_cntr_reg < (V_FP + FRAME_HEIGHT + V_PW - 1)) then
        v_sync_reg <= V_POL;
      else v_sync_reg <= not(V_POL); end if;
    end if;
  end process;

  active <= '1' when ((h_cntr_reg < FRAME_WIDTH) and (v_cntr_reg < FRAME_HEIGHT)) else '0';

  process (pxl_clk_bufg)
  begin
    if (rising_edge(pxl_clk_bufg)) then
      v_sync_dly_reg <= v_sync_reg;
      h_sync_dly_reg <= h_sync_reg;
      vga_red_reg <= vga_red;
      vga_green_reg <= vga_green;
      vga_blue_reg <= vga_blue;
    end if;
  end process;

  VGA_HS_O <= h_sync_dly_reg;
  VGA_VS_O <= v_sync_dly_reg;
  VGA_R <= vga_red_reg;
  VGA_G <= vga_green_reg;
  VGA_B <= vga_blue_reg;

end Behavioral;
