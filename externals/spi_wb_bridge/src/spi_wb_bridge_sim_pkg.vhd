library ieee;
   use ieee.std_logic_1164.all;

library uvvm_util;
   use uvvm_util.uvvm_util_context;
   use uvvm_util.adaptations_pkg.all;
   use uvvm_util.types_pkg.all;

library bitvis_vip_spi;
   use bitvis_vip_spi.spi_bfm_pkg.all;

library work;
   use work.spi_wb_bridge_pkg.all;


-- spi_wb_bridge_sim_pkg contains code that is intended to be used
-- only in simulations.
package spi_wb_bridge_sim_pkg is

   constant CLK_25_MHZ_PERIOD : time := 40 ns;
   constant CLK_6_MHZ_PERIOD  : time := 166 ns;

   constant WRITE_ADDR : std_logic_vector(6 downto 0) := "0011101";
   constant WRITE_DATA : std_logic_vector(31 downto 0) := x"DEADBEEF";

   constant READ_ADDR : std_logic_vector(6 downto 0) := "1010011";
   constant READ_DATA : std_logic_vector(31 downto 0) := x"DEADBEEF";

   constant SPI_BFM_CONFIG : t_spi_bfm_config := (
      CPOL             => '0',
      CPHA             => '0',
      spi_bit_time     => CLK_6_MHZ_PERIOD,
      ss_n_to_sclk     => 300 ns,
      sclk_to_ss_n     => 20 ns,
      inter_word_delay => 0 ns,
      match_strictness => MATCH_EXACT,
      id_for_bfm       => ID_BFM,
      id_for_bfm_wait  => ID_BFM_WAIT,
      id_for_bfm_poll  => ID_BFM_POLL
   );

   function crc8_ccitt (
      constant data_in : std_logic_vector(7 downto 0);
      constant crc_in  : std_logic_vector(7 downto 0)
   ) return std_logic_vector;

   function write_request (
      constant addr : std_logic_vector(6 downto 0);
      constant data : std_ulogic_vector(31 downto 0)
   ) return std_logic_vector;

   function read_request (
      constant addr : std_logic_vector(6 downto 0)
   ) return std_logic_vector;

   function get_read_status (
      constant rx_data : std_logic_vector(9 * 8 -1 downto 0)
   ) return t_status;

   function get_read_data (
      constant rx_data : std_logic_vector(9 * 8 -1 downto 0)
   ) return std_logic_vector;

   function get_write_status (
      constant rx_data : std_logic_vector(9 * 8 -1 downto 0)
   ) return t_status;

   function get_write_crc (
      constant rx_data : std_logic_vector(9 * 8 -1 downto 0)
   ) return std_logic_vector;

end package;


package body spi_wb_bridge_sim_pkg is

   function crc8_ccitt (
      constant data_in : std_logic_vector(7 downto 0);
      constant crc_in  : std_logic_vector(7 downto 0)
   ) return std_logic_vector is
      variable ret : std_logic_vector(7 downto 0);
   begin
      ret(0) := crc_in(0) xor crc_in(6) xor crc_in(7) xor data_in(0) xor data_in(6) xor data_in(7);
      ret(1) := crc_in(0) xor crc_in(1) xor crc_in(6) xor data_in(0) xor data_in(1) xor data_in(6);
      ret(2) := crc_in(0) xor crc_in(1) xor crc_in(2) xor crc_in(6) xor data_in(0) xor data_in(1) xor data_in(2) xor data_in(6);
      ret(3) := crc_in(1) xor crc_in(2) xor crc_in(3) xor crc_in(7) xor data_in(1) xor data_in(2) xor data_in(3) xor data_in(7);
      ret(4) := crc_in(2) xor crc_in(3) xor crc_in(4) xor data_in(2) xor data_in(3) xor data_in(4);
      ret(5) := crc_in(3) xor crc_in(4) xor crc_in(5) xor data_in(3) xor data_in(4) xor data_in(5);
      ret(6) := crc_in(4) xor crc_in(5) xor crc_in(6) xor data_in(4) xor data_in(5) xor data_in(6);
      ret(7) := crc_in(5) xor crc_in(6) xor crc_in(7) xor data_in(5) xor data_in(6) xor data_in(7);

      return ret;
   end function;


   function write_request (
      constant addr : std_logic_vector(6 downto 0);
      constant data: std_ulogic_vector(31 downto 0)
   ) return std_logic_vector is
      variable crc : std_logic_vector(7 downto 0) := (others => '1');
   begin
      crc := crc8_ccitt("1" & std_logic_vector(addr), crc);
      crc := crc8_ccitt(data(31 downto 24), crc);
      crc := crc8_ccitt(data(23 downto 16), crc);
      crc := crc8_ccitt(data(15 downto 8), crc);
      crc := crc8_ccitt(data(7 downto 0), crc);

      return "1" & std_logic_vector(addr) & data & crc;
   end function;


   function read_request (
      constant addr : std_logic_vector(6 downto 0)
   ) return std_logic_vector is
   begin
      return "0" & addr & crc8_ccitt("0" & addr, "11111111");
   end function;

   function get_read_status (
      constant rx_data : std_logic_vector(9 * 8 -1 downto 0)
   ) return t_status is
   begin
      return to_status(rx_data(47 downto 40));
   end function;


   function get_read_data (
      constant rx_data : std_logic_vector(9 * 8 -1 downto 0)
   ) return std_logic_vector is
   begin
      return rx_data(39 downto 8);
   end function;


   function get_write_status (
      constant rx_data : std_logic_vector(9 * 8 -1 downto 0)
   ) return t_status is
   begin
      return to_status(rx_data(15 downto 8));
   end function;


   function get_write_crc (
      constant rx_data : std_logic_vector(9 * 8 -1 downto 0)
   ) return std_logic_vector is
   begin
      return rx_data(7 downto 0);
   end function;

end package body;
