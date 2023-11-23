library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;

library uvvm_util;
   context uvvm_util.uvvm_util_context;

library bitvis_vip_wishbone;
   use bitvis_vip_wishbone.wishbone_bfm_pkg.all;

library general_cores;
   use general_cores.wishbone_pkg.all;

library work;
   use work.cosim.all;

library general_cores;
   use general_cores.wishbone_pkg.all;

library agwb;
   use agwb.Main_pkg.all;
   use agwb.Subblock_t_pkg.all;


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

   signal ca4 : ut_CA4_array (1 downto 0);
   signal ca2 : t_CA2;

   signal sa4 : ut_SA4_array (1 downto 0);
   signal sa2 : t_SA2;

   signal counter : unsigned(32 downto 0) := b"111111111111111111111111111111111";

   signal add0 : t_add0;
   signal add1 : t_add1;
   signal add1_stb : std_logic;

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


   agwb_main : entity agwb.Main
   port map (
      clk_sys_i => clk,
      rst_n_i => '1',
      slave_i => wb_ms,
      slave_o => wb_sm,
      Subblock_wb_m_o => subblock_wb_ms,
      Subblock_wb_m_i => subblock_wb_sm,


      C1_o => c1,
      C2_o => c2,
      C3_o => c3,

      S1_i => c1,
      S2_i => c2,
      S3_i => c3,

      CA4_o => ca4,
      CA2_o => ca2,

      SA4_i => sa4,
      SA2_i => sa2,

      Counter0_i => std_logic_vector(counter(31 downto 0)),
      Counter1_i => std_logic_vector(counter(32 downto 32)),

      Mask_o    => open,
      Version_i => x"010102"
   );


   agwb_subblock : entity agwb.Subblock_t
   port map (
      clk_sys_i => clk,
      rst_n_i => '1',
      slave_i => subblock_wb_ms,
      slave_o => subblock_wb_sm,

      add0_o => add0,
      add1_o => add1,
      add1_o_stb => add1_stb,
      sum_i => sum
   );


   sa4_assignemnt : for i in 0 to 1 generate
      sa4(i).Item0 <= ca4(i).Item0;
      sa4(i).Item1 <= ca4(i).Item1;
      sa4(i).Item2 <= ca4(i).Item2;
      sa4(i).Item3 <= ca4(i).Item3;
   end generate;

   sa2_assignemnt : process (ca2) is
   begin
      sa2.Item0 <= ca2.Item0;
      sa2.Item1 <= ca2.Item1;
   end process;


   Adder : process (clk) is
   begin
      if rising_edge(clk) then
         if add1_stb then
            sum <= std_logic_vector(
               resize(unsigned(add0.a), sum'length) +
               resize(unsigned(add0.b), sum'length) +
               resize(unsigned(add1.c), sum'length)
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
