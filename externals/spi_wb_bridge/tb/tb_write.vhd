library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;

library uvvm_util;
   use uvvm_util.uvvm_util_context;

library bitvis_vip_spi;
   use bitvis_vip_spi.spi_bfm_pkg.all;

library general_cores;
   use general_cores.wishbone_pkg.all;

library work;
   use work.spi_wb_bridge_pkg.all;
   use work.spi_wb_bridge_sim_pkg.all;


entity tb_write is
end entity;


architecture test of tb_write is
   signal clk : std_logic := '0';

   -- DUT ports
   signal sclk : std_logic;
   signal sdi  : std_logic;
   signal sdo  : std_logic;
   signal csn  : std_logic := '1';

   signal ms : t_wishbone_master_out;
   signal sm : t_wishbone_master_in;

   -- Testbench specific signals
   signal master_stb_prev : std_logic := '0';

   constant tx_data : std_logic_vector(9 * 8 - 1 downto 0) := write_request(WRITE_ADDR, WRITE_DATA) & x"000000";

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
      variable status : t_status;
      variable crc, crc_expected : std_logic_vector(7 downto 0);
   begin
      wait for 5 * CLK_25_MHZ_PERIOD;

      spi_master_transmit_and_receive(tx_data, rx_data, "rx data", sclk, csn, sdi, sdo, config => SPI_BFM_CONFIG);

      status := get_write_status(rx_data);

      assert status = SUCCESS
         report "write request failed, status: " & to_str(status)
         severity failure;

      crc := get_write_crc(rx_data);
      crc_expected := crc8_ccitt(to_slv(status), "11111111");
      assert crc = crc_expected
         report "wrong crc " & to_string(crc) & " expecting " & to_string(crc_expected)
         severity failure;

      wait for 10 * CLK_25_MHZ_PERIOD;
      std.env.finish;
   end process;


   master_stb_guard : process (clk) is
   begin
      -- Assert master stb signal is asserted only for single clock cycle.
      if rising_edge(clk) then
         if master_stb_prev = '1' then
            assert ms.stb = '0'
               report "bus master stb asserted for more than one clock cycle"
               severity failure;
         end if;
      end if;
   end process;


   internal_slave : process (clk) is
   begin
      if rising_edge(clk) then
         sm.ack <= '0';
         if ms.stb = '1' then
            assert ms.we = '1'
               report "ms.we /= '1', expecting write transaction"
               severity failure;
            assert ms.adr(6 downto 0) = WRITE_ADDR
               report "ms.adr = " & to_hstring(ms.adr) & ", expecting " & to_hstring(WRITE_ADDR)
               severity failure;
            assert ms.dat = WRITE_DATA
               report "ms.dat = " & to_hstring(ms.dat) & ", expecting " & to_hstring(WRITE_DATA)
               severity failure;

            sm.ack <= '1';
            sm.err <= '0';
            sm.rty <= '0';
         end if;
      end if;
   end process;

end architecture;
