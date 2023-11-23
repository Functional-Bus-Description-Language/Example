-- This file has been automatically generated by the vfbdb tool.
-- Do not edit it manually, unless you really know what you do.
-- https://github.com/Functional-Bus-Description-Language/go-vfbdb

library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;

library ltypes;
   use ltypes.types.all;

library work;
   use work.wb3.all;


package Main_pkg is

-- Constants

-- Proc types

-- Stream types

end package;


library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;

library general_cores;
   use general_cores.wishbone_pkg.all;

library ltypes;
   use ltypes.types.all;

library work;
   use work.wb3.all;
   use work.Main_pkg.all;


entity Main is
generic (
   G_REGISTERED : boolean := true
);
port (
   clk_i : in std_logic;
   rst_i : in std_logic;
   slave_i : in  t_wishbone_slave_in_array (1 - 1 downto 0);
   slave_o : out t_wishbone_slave_out_array(1 - 1 downto 0);
   ID_o : out std_logic_vector(31 downto 0) := x"e2c709ee";
   S1_i : in std_logic_vector(6 downto 0);
   S2_i : in std_logic_vector(8 downto 0);
   S3_i : in std_logic_vector(11 downto 0);
   C1_o : buffer std_logic_vector(6 downto 0);
   C2_o : buffer std_logic_vector(8 downto 0);
   C3_o : buffer std_logic_vector(11 downto 0)
);
end entity;


architecture rtl of Main is

constant C_ADDRESSES : t_wishbone_address_array(0 downto 0) := (0 => "00000000000000000000000000000000");
constant C_MASKS     : t_wishbone_address_array(0 downto 0) := (0 => "00000000000000000000000000000000");

signal master_out : t_wishbone_master_out;
signal master_in  : t_wishbone_master_in;


begin

crossbar: entity general_cores.xwb_crossbar
generic map (
   G_NUM_MASTERS => 1,
   G_NUM_SLAVES  => 0 + 1,
   G_REGISTERED  => G_REGISTERED,
   G_ADDRESS     => C_ADDRESSES,
   G_MASK        => C_MASKS
)
port map (
   clk_sys_i   => clk_i,
   rst_n_i     => not rst_i,
   slave_i     => slave_i,
   slave_o     => slave_o,
   master_i(0) => master_in,
   master_o(0) => master_out
);


register_access : process (clk_i) is

variable addr : natural range 0 to 7 - 1;

begin

if rising_edge(clk_i) then

-- Normal operation.
master_in.rty <= '0';
master_in.ack <= '0';
master_in.err <= '0';

-- Procs Calls Clear
-- Procs Exits Clear
-- Stream Strobes Clear

transfer : if
   master_out.cyc = '1'
   and master_out.stb = '1'
   and master_in.err = '0'
   and master_in.rty = '0'
   and master_in.ack = '0'
then
   addr := to_integer(unsigned(master_out.adr(3 - 1 downto 0)));

   -- First assume there is some kind of error.
   -- For example internal address is invalid or there is a try to write status.
   master_in.err <= '1';
   -- '0' for security reasons, '-' can lead to the information leak.
   master_in.dat <= (others => '0');
   master_in.ack <= '0';

   -- Registers Access
   if 0 <= addr and addr <= 0 then
      master_in.dat(31 downto 0) <= x"e2c709ee"; -- ID

      master_in.ack <= '1';
      master_in.err <= '0';
   end if;

   if 1 <= addr and addr <= 1 then

      if master_out.we = '1' then
         C1_o <= master_out.dat(6 downto 0);
      end if;
      master_in.dat(6 downto 0) <= C1_o;

      master_in.ack <= '1';
      master_in.err <= '0';
   end if;

   if 2 <= addr and addr <= 2 then

      if master_out.we = '1' then
         C2_o <= master_out.dat(8 downto 0);
      end if;
      master_in.dat(8 downto 0) <= C2_o;

      master_in.ack <= '1';
      master_in.err <= '0';
   end if;

   if 3 <= addr and addr <= 3 then

      if master_out.we = '1' then
         C3_o <= master_out.dat(11 downto 0);
      end if;
      master_in.dat(11 downto 0) <= C3_o;

      master_in.ack <= '1';
      master_in.err <= '0';
   end if;

   if 4 <= addr and addr <= 4 then
      master_in.dat(11 downto 0) <= S3_i;


      master_in.ack <= '1';
      master_in.err <= '0';
   end if;

   if 5 <= addr and addr <= 5 then
      master_in.dat(8 downto 0) <= S2_i;


      master_in.ack <= '1';
      master_in.err <= '0';
   end if;

   if 6 <= addr and addr <= 6 then
      master_in.dat(6 downto 0) <= S1_i;


      master_in.ack <= '1';
      master_in.err <= '0';
   end if;


   -- Proc Calls Set
   -- Proc Exits Set
   -- Stream Strobes Set

end if transfer;

if rst_i = '1' then
   master_in <= C_DUMMY_WB_MASTER_IN;
end if;
end if;
end process register_access;


-- Combinational processes


end architecture;
