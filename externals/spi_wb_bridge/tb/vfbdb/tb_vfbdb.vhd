library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;

library uvvm_util;
   use uvvm_util.uvvm_util_context;

library bitvis_vip_spi;
   use bitvis_vip_spi.spi_bfm_pkg.all;

library general_cores;
   use general_cores.wishbone_pkg.all;

library vfbdb;

library work;
   use work.spi_wb_bridge_pkg.all;
   use work.spi_wb_bridge_sim_pkg.all;


entity tb_vfbdb is
end entity;

architecture test of tb_vfbdb is

   signal clk : std_logic := '0';

   -- DUT ports
   signal sclk : std_logic;
   signal sdi  : std_logic;
   signal sdo  : std_logic;
   signal csn  : std_logic := '1';

   signal ms : t_wishbone_master_out := (
      cyc => '0',
      stb => '0',
      adr => (others => '0'),
      sel => (others => '0'),
      we  => '0',
      dat => (others => '0')
   );
   signal sm : t_wishbone_master_in;

   constant WRITE_READ_ADDR : std_logic_vector(6 downto 0) := "0000010";

   constant tx_write_data : std_logic_vector(9 * 8 - 1 downto 0) := write_request(WRITE_READ_ADDR, WRITE_DATA) & x"000000";
   constant tx_read_data : std_logic_vector(9 * 8 - 1 downto 0) := read_request(WRITE_READ_ADDR) & x"00000000000000";

begin

   clk <= not clk after CLK_25_MHZ_PERIOD / 2;


   DUT : entity work.SPI_Wb_Bridge
   port map (
      clk_i  => clk,
      sclk_i => sclk,
      sdi_i  => sdi,
      sdo_o  => sdo,
      csn_i  => csn,
      ms_o   => ms,
      sm_i   => sm
   );


   main : process is
      variable rx_data : std_logic_vector(9 * 8 - 1 downto 0);
   begin
      wait for 5 * CLK_25_MHZ_PERIOD;

      spi_master_transmit_and_receive(tx_write_data, rx_data, "rx data", sclk, csn, sdi, sdo, config => SPI_BFM_CONFIG);
      wait for 5 * CLK_25_MHZ_PERIOD;
      spi_master_transmit_and_receive(tx_read_data, rx_data, "rx data", sclk, csn, sdi, sdo, config => SPI_BFM_CONFIG);

      wait for 5 * CLK_25_MHZ_PERIOD;
      std.env.finish;
   end process;


   vfbdb_main : entity vfbdb.Main
   port map(
      clk_i      => clk,
      rst_i      => '0',
      slave_i(0) => ms,
      slave_o(0) => sm,

      Write_Read_Test_o => open
   );

   err_rty_guard : process (clk) is
   begin
      if rising_edge(clk) then
         assert sm.err = '0' report "bus error" severity failure;
         assert sm.rty = '0' report "bus retry" severity failure;
      end if;
   end process;

end architecture;
