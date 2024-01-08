library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;

library general_cores;
   use general_cores.wishbone_pkg.all;

library ltypes;
   use ltypes.types.all;

library agwb;
   use agwb.Main_pkg.all;
   use agwb.Subblock_t_pkg.all;

entity Top_AGWB is
   port (
      clk_i : in std_logic;

      -- MCU SPI
      sclk_i : in  std_logic;
      sdi_i  : in  std_logic;
      sdo_o  : out std_logic;
      csn_i  : in  std_logic
   );
end entity;


architecture Structural of Top_AGWB is

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

   signal counter : unsigned(32 downto 0) := b"111111111111111111111111100000110";

   signal add0 : t_add0;
   signal add1 : t_add1;
   signal add1_stb : std_logic;

   signal sum : std_logic_vector(20 downto 0);

   signal add_stream0     : t_add_stream0;
   signal add_stream1     : t_add_stream1;
   signal add_stream1_stb : std_logic;

   signal sum_stream     : t_sum_stream;
   signal sum_stream_ack : std_logic;

   signal sum_buff : slv_vector(0 to 15)(20 downto 0);
   signal sum_buff_write_ptr, sum_buff_read_ptr : natural := 0;

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


   agwb_main : entity agwb.Main
   port map (
      clk_sys_i => clk_i,
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

      Mask_o    => mask,
      Version_i => x"010102"
   );


   agwb_subblock : entity agwb.Subblock_t
   port map (
      clk_sys_i => clk_i,
      rst_n_i => '1',
      slave_i => subblock_wb_ms,
      slave_o => subblock_wb_sm,

      add0_o => add0,
      add1_o => add1,
      add1_o_stb => add1_stb,
      sum_i => sum,

      add_stream0_o     => add_stream0,
      add_stream1_o     => add_stream1,
      add_stream1_o_stb => add_stream1_stb,

      sum_stream_i    => sum_stream,
      sum_stream_i_ack => sum_stream_ack
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


   Adder : process (clk_i) is
   begin
      if rising_edge(clk_i) then
         if add1_stb then
            sum <= std_logic_vector(
               resize(unsigned(add0.a), sum'length) +
               resize(unsigned(add0.b), sum'length) +
               resize(unsigned(add1.c), sum'length)
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


   Add_Stream_Driver : process (clk_i) is
   begin
      if rising_edge(clk_i) then
         if add_stream1_stb = '1' then
            sum_buff(sum_buff_write_ptr) <= std_logic_vector(
               resize(unsigned(add_stream0.a), sum_buff(0)'length) +
               resize(unsigned(add_stream0.b), sum_buff(0)'length) +
               resize(unsigned(add_stream1.c), sum_buff(0)'length)
            );
            sum_buff_write_ptr <= sum_buff_write_ptr + 1;
         end if;
      end if;
   end process;


   sum_stream <= sum_buff(sum_buff_read_ptr);


   Sum_Stream_Driver : process (clk_i) is
   begin
      if rising_edge(clk_i) then
         if sum_stream_ack = '1' then
            sum_buff_read_ptr <= (sum_buff_read_ptr + 1) mod 16;
         end if;
      end if;
   end process;

end architecture;
