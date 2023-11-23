--- This file has been automatically generated
--- by the agwb (https://github.com/wzab/agwb).
--- Please don't edit it manually, unless you really have to do it
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library general_cores;
use general_cores.wishbone_pkg.all;

package agwb_pkg is


  constant c_WB_SLAVE_OUT_ERR : t_wishbone_slave_out :=
    (ack => '0', err => '1', rty => '0', stall => '0', dat => c_DUMMY_WB_DATA);

  type t_reps_variants is array (integer range <>) of integer;
  type t_ver_id_variants is array (integer range <>) of std_logic_vector(31 downto 0);
   function agwb_and(a : std_logic_vector; b : std_logic_vector ) return std_logic_vector;

end package agwb_pkg;

package body agwb_pkg is

  function agwb_and(a:std_logic_vector; b:std_logic_vector) return std_logic_vector is
  variable res : std_logic_vector(a'range);
  begin
     res := a and b;
     return res;
  end function;

end agwb_pkg;

