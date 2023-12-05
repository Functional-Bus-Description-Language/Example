library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;

library general_cores;
   use general_cores.wishbone_pkg.all;

library vfbdb;
   use vfbdb.wb3;
   use vfbdb.wb3.all;
   use vfbdb.Main_pkg.all;
   use vfbdb.Subblock_pkg.all;

library ltypes;
   use ltypes.types.all;


-- Debug ports (dbg0_o, dbg1_o) can be used however one wants.
-- Anyone is free to change theirs behavior and commit the change.
entity Top_FBDL is
   port (
      clk_i : in std_logic;

      -- MCU SPI
      sclk_i : in  std_logic;
      sdi_i  : in  std_logic;
      sdo_o  : out std_logic;
      csn_i  : in  std_logic
   );
end entity;


architecture Structural of Top_FBDL is

   signal wb_ms: t_wishbone_master_out;
   signal wb_sm: t_wishbone_slave_out;

   signal subblock_wb_ms: t_wishbone_master_out;
   signal subblock_wb_sm: t_wishbone_slave_out;

   signal c1 : std_logic_vector(6 downto 0);
   signal c2 : std_logic_vector(8 downto 0);
   signal c3 : std_logic_vector(11 downto 0);

   signal ca : slv_vector(9 downto 0)(7 downto 0);

   signal counter : unsigned(32 downto 0) := b"111111111111111111111111101110110";

   signal add_out : add_out_t;
   signal add_in  : add_in_t;

   signal mask : std_logic_vector(15 downto 0);


begin

   SPI_Wb_Bridge : entity work.SPI_Wb_Bridge
   port map (
      clk_i  => clk_i,
      sclk_i => sclk_i,
      sdi_i  => sdi_i,
      sdo_o  => sdo_o,
      csn_i  => csn_i,
      ms_o   => wb_ms,
      sm_i   => wb_sm
   );


   vfbdb_main : entity vfbdb.Main
   port map (
      clk_i => clk_i,
      rst_i => '0',
      slave_i(0) => wb_ms,
      slave_o(0) => wb_sm,
      subblock_master_o(0) => subblock_wb_ms,
      subblock_master_i(0) => subblock_wb_sm,

      C1_o => c1,
      C2_o => c2,
      C3_o => c3,

      S1_i => c1,
      S2_i => c2,
      S3_i => c3,

      CA_o => ca,
      SA_i => ca,

      Counter_i => std_logic_vector(counter),

      Mask_o => mask
   );


   vfbdb_subblock : entity vfbdb.Subblock
   port map (
      clk_i   => clk_i,
      rst_i   => '0',
      slave_i(0)=> subblock_wb_ms,
      slave_o(0)=> subblock_wb_sm,

      Add_o => add_out,
      Add_i => add_in
   );


   Adder : process (clk_i) is
   begin
      if rising_edge(clk_i) then
         if add_out.call then
            add_in.sum <= std_logic_vector(
               resize(unsigned(add_out.a), add_in.sum'length) +
               resize(unsigned(add_out.b), add_in.sum'length) +
               resize(unsigned(add_out.c), add_in.sum'length)
            );
         end if;
      end if;
   end process;


   Counter_Mock : process(clk_i) is
   begin
      if rising_edge(clk_i) then
         counter <= counter + 1;
      end if;
   end process;

end architecture;
