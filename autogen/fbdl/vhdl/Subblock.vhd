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


package Subblock_pkg is

-- Constants

-- Proc types

type Add_out_t is record
   A : std_logic_vector(19 downto 0);
   B : std_logic_vector(9 downto 0);
   C : std_logic_vector(7 downto 0);
   call : std_logic;
   exitt : std_logic;
end record;

type Add_in_t is record
   Sum : std_logic_vector(20 downto 0);
end record;

-- Stream types

type Add_Stream_t is record
   A : std_logic_vector(19 downto 0);
   B : std_logic_vector(9 downto 0);
   C : std_logic_vector(7 downto 0);
end record;

type Sum_Stream_t is record
   Sum : std_logic_vector(20 downto 0);
end record;

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
   use work.Subblock_pkg.all;


entity Subblock is
generic (
   G_REGISTERED : boolean := true
);
port (
   clk_i : in std_logic;
   rst_i : in std_logic;
   slave_i : in  t_wishbone_slave_in_array (1 - 1 downto 0);
   slave_o : out t_wishbone_slave_out_array(1 - 1 downto 0);
   Add_o : out Add_out_t;
   Add_i : in Add_in_t;
   Add_Stream_o : out Add_Stream_t;
   Add_Stream_stb_o : out std_logic;
   Sum_Stream_i : in Sum_Stream_t;
   Sum_Stream_stb_o : out std_logic
);
end entity;


architecture rtl of Subblock is

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

variable addr : natural range 0 to 5 - 1;

begin

if rising_edge(clk_i) then

-- Normal operation.
master_in.rty <= '0';
master_in.ack <= '0';
master_in.err <= '0';

-- Procs Calls Clear
Add_o.call <= '0';
-- Procs Exits Clear
Add_o.exitt <= '0';
-- Stream Strobes Clear
Add_Stream_stb_o <= '0';
Sum_Stream_stb_o <= '0';

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

      if master_out.we = '1' then
         Add_o.A <= master_out.dat(19 downto 0);
      end if;
      master_in.dat(19 downto 0) <= Add_o.A;
      if master_out.we = '1' then
         Add_o.B <= master_out.dat(29 downto 20);
      end if;
      master_in.dat(29 downto 20) <= Add_o.B;
      if master_out.we = '1' then
         Add_o.C(1 downto 0) <= master_out.dat(31 downto 30);
      end if;
      master_in.dat(31 downto 30) <= Add_o.C(1 downto 0);

      master_in.ack <= '1';
      master_in.err <= '0';
   end if;

   if 1 <= addr and addr <= 1 then

      if master_out.we = '1' then
         Add_o.C(7 downto 2) <= master_out.dat(5 downto 0);
      end if;
      master_in.dat(5 downto 0) <= Add_o.C(7 downto 2);      master_in.dat(26 downto 6) <= Add_i.Sum;


      master_in.ack <= '1';
      master_in.err <= '0';
   end if;

   if 2 <= addr and addr <= 2 then

      if master_out.we = '1' then
         Add_Stream_o.A <= master_out.dat(19 downto 0);
      end if;

      if master_out.we = '1' then
         Add_Stream_o.B <= master_out.dat(29 downto 20);
      end if;

      if master_out.we = '1' then
         Add_Stream_o.C(1 downto 0) <= master_out.dat(31 downto 30);
      end if;


      master_in.ack <= '1';
      master_in.err <= '0';
   end if;

   if 3 <= addr and addr <= 3 then

      if master_out.we = '1' then
         Add_Stream_o.C(7 downto 2) <= master_out.dat(5 downto 0);
      end if;


      master_in.ack <= '1';
      master_in.err <= '0';
   end if;

   if 4 <= addr and addr <= 4 then
      master_in.dat(20 downto 0) <= Sum_Stream_i.Sum;


      master_in.ack <= '1';
      master_in.err <= '0';
   end if;


   -- Proc Calls Set
   Add_call : if addr = 1 then
      if master_out.we = '1' then
         Add_o.call <= '1';
      end if;
   end if;

   -- Proc Exits Set
   Add_exit : if addr = 1 then
      if master_out.we = '0' then
         Add_o.exitt <= '1';
      end if;
   end if;

   -- Stream Strobes Set
   Add_Stream_stb : if addr = 3 then
      if master_out.we = '1' then
         Add_Stream_stb_o <= '1';
      end if;
   end if;

   Sum_Stream_stb : if addr = 4 then
      if master_out.we = '0' then
         Sum_Stream_stb_o <= '1';
      end if;
   end if;


end if transfer;

if rst_i = '1' then
   master_in <= C_DUMMY_WB_MASTER_IN;
end if;
end if;
end process register_access;


-- Combinational processes


end architecture;
