library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;

library work;
   context work.cosim_context;
   use work.cosim.all;

library general_cores;
   use general_cores.wishbone_pkg.all;

library vfbdb;
   use vfbdb.Main_pkg.all;
   use vfbdb.Subblock_pkg.all;


entity tb is
end entity;


architecture sim of tb is

   constant CLK_PERIOD : time := 50 ns;
   signal clk : std_logic := '0';

   -- Wishbone interfaces.
   signal uvvm_wb_if : t_wishbone_if (
      dat_o(31 downto 0),
      dat_i(31 downto 0),
      adr_o(31 downto 0)
   ) := init_wishbone_if_signals(32, 32);

   signal wb_ms: t_wishbone_master_out;
   signal wb_sm: t_wishbone_slave_out;

   signal subblock_wb_ms: t_wishbone_master_out;
   signal subblock_wb_sm: t_wishbone_slave_out;

   signal c1 : std_logic_vector(6 downto 0);
   signal c2 : std_logic_vector(8 downto 0);
   signal c3 : std_logic_vector(11 downto 0);

   signal ca : slv_vector(9 downto 0)(7 downto 0);

   signal counter : unsigned(31 downto 0) := (1 to 31 => '1', others => '0');

   signal add : add_out_t;
   signal sum : std_logic_vector(20 downto 0);

begin

   clk <= not clk after CLK_PERIOD / 2;


   wb_ms.cyc <= uvvm_wb_if.cyc_o;
   wb_ms.stb <= uvvm_wb_if.stb_o;
   wb_ms.adr <= uvvm_wb_if.adr_o;
   wb_ms.sel <= (others => '0');
   wb_ms.we  <= uvvm_wb_if.we_o;
   wb_ms.dat <= uvvm_wb_if.dat_o;

   uvvm_wb_if.dat_i <= wb_sm.dat;
   uvvm_wb_if.ack_i <= wb_sm.ack;

   cosim_interface("/tmp/fbdl-example/python-vhdl", "/tmp/fbdl-example/vhdl-python", clk, uvvm_wb_if, C_WB_BFM_CONFIG);


   vfbdb_main : entity vfbdb.Main
   port map (
      clk_i => clk,
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

      Mask_o => open
   );


   vfbdb_subblock : entity vfbdb.Subblock
   port map (
      clk_i   => clk,
      rst_i   => '0',
      slave_i(0)=> subblock_wb_ms,
      slave_o(0)=> subblock_wb_sm,

      Add_o => add,
      Sum_i => sum
   );


   Adder : process (clk) is
   begin
      if rising_edge(clk) then
         if add.call then
            sum <= std_logic_vector(
               resize(unsigned(add.a), sum'length) +
               resize(unsigned(add.b), sum'length) +
               resize(unsigned(add.c), sum'length)
            );
         end if;
      end if;
   end process;


   Counter_Mock : process(clk) is
   begin
      if rising_edge(clk) then
         counter <= counter + 1;
      end if;
   end process;

end architecture;
