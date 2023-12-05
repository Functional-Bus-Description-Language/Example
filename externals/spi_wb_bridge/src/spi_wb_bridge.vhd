-- Copyright (c) 2022 Fluence sp. z o. o.

library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;

library general_cores;
  use general_cores.wishbone_pkg.all;

library regs;

library work;
   use work.spi_wb_bridge_pkg.all;


-- SPI_Wb_Bridge allows access to the interval Wishbone bus vis SPI interface.
--
-- CPOL = 0 - sclk_i = 0 in idle state.
-- CPHA = 1 (almost) - sdi_i sampled on the rising edge, sdo_o shifted on the falling edge.
-- The actual sdo_o change happens after 2nd and before 3rd clk_i clock cycle.
-- Hence maximum sclk_i frequency should not be higher than (clk_i frequency) / 4.
--
-- csn_i to sclk_i time must be greater than clk_i PERIOD.
--
-- The bit and byte numbering is MSB first.
--
-- The module resets when csn_i is asserted.
--
-- Write access:
--   Request:
--     Byte:   1st               2nd                   3rd                   4th                   5th            6th     7th
--     --------------------------------------------------------------------------------------------------------------------------
--     || '1' | ADDRESS || DATA (31 downto 24) || DATA(23 downto 16) || DATA(15 downto 8) || DATA (7 downto 0) || CRC || DUMMY ||
--     --------------------------------------------------------------------------------------------------------------------------
--   Response:
--     Byte: 1st    2nd
--     -------------------
--     || STATUS || CRC ||
--     -------------------
--
-- Read access:
--   Request:
--     Byte:   1st         2nd     3rd
--     -----------------------------------
--     || '0' | ADDRESS || CRC || DUMMY ||
--     -----------------------------------
--   Response:
--     Byte: 1st          2nd                   3rd                   4th                   5th            6th
--     ----------------------------------------------------------------------------------------------------------
--     || STATUS || DATA (31 downto 24) || DATA(23 downto 16) || DATA(15 downto 8) || DATA (7 downto 0) || CRC ||
--     ----------------------------------------------------------------------------------------------------------
--
-- CRC is always CRC-8-CCITT (x^8 + x^2 + x + 1) with initial value 0xFF.
--
-- DUMMY byte is needed to give internal bus a time to carry out a transaction.
-- 
-- STATUS values:
--   Check spi_wb_bridge_pkg t_status.
entity SPI_Wb_Bridge is
   port (
      clk_i : in std_logic;

      -- SPI
      sclk_i : in  std_logic;
      sdi_i  : in  std_logic;
      sdo_o  : out std_logic;
      csn_i  : in  std_logic;

      -- Internal bus interface
      ms_o : out t_wishbone_master_out := C_DUMMY_WB_MASTER_OUT;
      sm_i : in  t_wishbone_master_in
   );
end entity;


architecture mixed of SPI_Wb_Bridge is

   -- SPI synchronized to the clk_i clock domain.
   signal sclk : std_logic;
   signal sdi  : std_logic;
   signal csn_synced, csn  : std_logic;

   constant CSN_FILTER_CHAIN_LENGTH : positive := 8;
   signal csn_filter_chain : std_logic_vector(CSN_FILTER_CHAIN_LENGTH downto 0) := (others => '1');

   signal sclk_prev         : std_logic;
   signal sclk_rising_edge  : std_logic;
   signal sclk_falling_edge : std_logic;

   type t_command is record
      write : std_logic;
      addr  : std_logic_vector(6 downto 0);
   end record;
   function to_slv(cmd : t_command) return std_logic_vector is
      variable ret : std_logic_vector(7 downto 0);
   begin
      ret(7) := cmd.write;
      ret(6 downto 0) := cmd.addr;
      return ret;
   end function;
   signal command : t_command;
   signal rx_crc : std_logic_vector(7 downto 0);

   signal slave_data : std_logic_vector(31 downto 0);

   -- CRC
   signal crc_in, crc_out : std_logic_vector(7 downto 0);
   signal crc_en, crc_rst : std_logic;

   subtype t_bit_pointer is natural range 0 to 7;
   signal bit_pointer : t_bit_pointer := t_bit_pointer'high;

   subtype t_byte_pointer is natural range 0 to 3;
   signal byte_pointer : t_byte_pointer := t_byte_pointer'high;

   type t_state is (IDLE, CMD_RCV, DATA_RCV, CRC_RCV, TRANSACTION, SEND_STATUS, SEND_DATA, SEND_CRC);
   signal state : t_state := IDLE;

   signal status : t_status;

begin

   spi_synchronizer : entity regs.False_Path_Synchronizer
   generic map (
      WIDTH => 3
   )
   port map (
      clk_i  => clk_i,
      d_i(0) => sclk_i,
      d_i(1) => sdi_i,
      d_i(2) => csn_i,
      q_o(0) => sclk,
      q_o(1) => sdi,
      q_o(2) => csn_synced
   );


   -- CSN_Filter is theoretically not requiredr. However, when prototyping with Bus Pirate
   -- board very short (single 25 MHz clock cycle) spikes were observed.
   CSN_Filter : process (clk_i) is
      variable zero_count : natural;
   begin
      if rising_edge(clk_i) then
         csn_filter_chain(CSN_FILTER_CHAIN_LENGTH - 1 downto 1) <= csn_filter_chain(CSN_FILTER_CHAIN_LENGTH - 2 downto 0);
         csn_filter_chain(0) <= csn_synced;

         zero_count := 0;
         for i in 0 to CSN_FILTER_CHAIN_LENGTH - 1 loop
            if csn_filter_chain(i) = '0' then
               zero_count := zero_count + 1;
            end if;
         end loop;

         csn <= '1';
         if zero_count > CSN_FILTER_CHAIN_LENGTH / 2 then
            csn <= '0';
         end if;
      end if;
   end process;


   process (clk_i) is
   begin
      if rising_edge(clk_i) then
         sclk_prev <= sclk;
      end if;
   end process;


   sclk_rising_edge  <= '1' when sclk_prev = '0' and sclk = '1' else '0';
   sclk_falling_edge <= '1' when sclk_prev = '1' and sclk = '0' else '0';


   crc8_ccitt : entity work.CRC8_CCITT
   port map (
      data_in => crc_in,
      clk     => clk_i,
      rst     => crc_rst,
      crc_en  => crc_en,
      crc_out => crc_out
   );


   process (clk_i) is

      procedure end_wb_cycle is
      begin
         ms_o.stb <= '0';
         ms_o.cyc <= '0';
      end procedure;

   begin
      if rising_edge(clk_i) then
         crc_rst <= '0';
         crc_en <= '0';

         case state is
         when IDLE =>
            ms_o.cyc <= '0';
            ms_o.stb <= '0';
            if csn = '0' then
               state <= CMD_RCV;
            end if;
         when CMD_RCV =>
            if sclk_rising_edge = '1' then
               if bit_pointer = t_bit_pointer'high then
                  bit_pointer <= bit_pointer - 1;
                  command.write <= sdi;
               elsif bit_pointer = 0 then
                  bit_pointer <= t_bit_pointer'high;
                  command.addr(0) <= sdi;
                  if command.write = '1' then
                     state <= DATA_RCV;
                  else
                     state <= CRC_RCV;
                  end if;

                  crc_in <= to_slv(command);
                  crc_in(0) <= sdi;
                  crc_en <= '1';
               else
                  bit_pointer <= bit_pointer - 1;
                  command.addr(bit_pointer) <= sdi;
               end if;
            end if;
         when DATA_RCV =>
            if sclk_rising_edge = '1' then
               ms_o.dat(byte_pointer * 8 + bit_pointer) <= sdi;
               crc_in(bit_pointer) <= sdi;
               crc_in(0) <= sdi;
               if bit_pointer = 0 then
                  bit_pointer <= t_bit_pointer'high;

                  crc_en <= '1';

                  if byte_pointer = 0 then
                     byte_pointer <= t_byte_pointer'high;
                     state <= CRC_RCV;
                  else
                     byte_pointer <= byte_pointer - 1;
                  end if;
               else
                  bit_pointer <= bit_pointer - 1;
               end if;
            end if;
         when CRC_RCV =>
            if sclk_rising_edge = '1' then
               rx_crc(bit_pointer) <= sdi;
               if bit_pointer = 0 then
                  bit_pointer <= t_bit_pointer'high;
                  state <= TRANSACTION;
               else
                  bit_pointer <= bit_pointer - 1;
               end if;
            end if;
         when TRANSACTION =>
            if status = BUS_ERROR then
               if sm_i.ack = '1' then
                  status <= SUCCESS;
                  slave_data <= sm_i.dat;
                  end_wb_cycle;
               elsif sm_i.err = '1' then
                  end_wb_cycle;
               elsif sm_i.rty = '1' then
                  status <= BUS_RETRY;
                  end_wb_cycle;
               end if;
            end if;

            if sclk_falling_edge = '1' then
               if bit_pointer = 7 then
                  bit_pointer <= bit_pointer - 1;
                  ms_o.we <= command.write;
                  ms_o.adr(6 downto 0) <= command.addr;
                  if crc_out /= rx_crc then
                     status <= INVALID_CRC;
                  else
                     status <= BUS_ERROR;
                     ms_o.cyc <= '1';
                     ms_o.stb <= '1';
                  end if;
               elsif bit_pointer > 0 then
                  bit_pointer <= bit_pointer - 1;
               else
                  bit_pointer <= t_bit_pointer'high;
                  crc_rst <= '1';
                  state <= SEND_STATUS;
               end if;
            end if;
         when SEND_STATUS =>
            if sclk_rising_edge = '1' then
               sdo_o <= to_slv(status)(bit_pointer);
               if bit_pointer = 0 then
                  bit_pointer <= t_bit_pointer'high;
                  crc_in <= to_slv(status);
                  crc_en <= '1';
                  if command.write = '1' then
                     state <= SEND_CRC;
                  else
                     state <= SEND_DATA;
                  end if;
               else
                  bit_pointer <= bit_pointer - 1;
               end if;
            end if;
         when SEND_DATA =>
            if sclk_rising_edge = '1' then
               sdo_o <= slave_data(byte_pointer * 8 + bit_pointer);
               crc_in(bit_pointer) <= slave_data(byte_pointer * 8 + bit_pointer);
               if bit_pointer = t_bit_pointer'high then
                  bit_pointer <= bit_pointer - 1;
                  crc_in <= slave_data((byte_pointer + 1) * 8 - 1 downto byte_pointer * 8);
                  crc_en <= '1';
               elsif bit_pointer = 0 then
                  bit_pointer <= t_bit_pointer'high;
                  if byte_pointer = 0 then
                     byte_pointer <= t_byte_pointer'high;
                     state <= SEND_CRC;
                  else
                     byte_pointer <= byte_pointer - 1;
                  end if;
               else
                  bit_pointer <= bit_pointer - 1;
               end if;
            end if;
         when SEND_CRC =>
            if sclk_rising_edge = '1' then
               sdo_o <= crc_out(bit_pointer);
               if bit_pointer = 0 then
                  bit_pointer <= t_bit_pointer'high;
                  state <= IDLE;
               else
                  bit_pointer <= bit_pointer - 1;
               end if;
            end if;
         end case;

         if csn = '1' then
            state <= IDLE;
            bit_pointer <= t_bit_pointer'high;
            byte_pointer <= t_byte_pointer'high;
            crc_rst <= '1';
            sdo_o <= '0';
         end if;
      end if;
   end process;

end architecture;
