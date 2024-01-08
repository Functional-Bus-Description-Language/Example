--- This file has been automatically generated
--- by the agwb (https://github.com/wzab/agwb).
--- Please don't edit it manually, unless you really have to do it
library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library general_cores;
use general_cores.wishbone_pkg.all;

library work;
use work.agwb_pkg.all;

package Subblock_t_pkg is

  constant C_Subblock_t_ADDR_BITS : integer := 3;

  constant c_Subblock_t_ver_id : std_logic_vector(31 downto 0) := x"ac8b5742";
  constant v_Subblock_t_ver_id : t_ver_id_variants(0 downto 0) := (0 => x"ac8b5742");
  constant c_Add0_size : integer := 1;
  constant c_Add1_size : integer := 1;
  constant c_Sum_size : integer := 1;
  constant c_Add_Stream0_size : integer := 1;
  constant c_Add_Stream1_size : integer := 1;
  constant c_Sum_Stream_size : integer := 1;


  constant C_Add0_REG_ADDR: unsigned := x"00000002";
  type t_Add0 is record
    A:std_logic_vector(19 downto 0);
    B:std_logic_vector(9 downto 0);
  end record;
  
  function to_Add0(x : std_logic_vector) return t_Add0;
  function to_slv(x : t_Add0) return std_logic_vector;
  constant C_Add1_REG_ADDR: unsigned := x"00000003";
  type t_Add1 is record
    C:std_logic_vector(7 downto 0);
  end record;
  
  function to_Add1(x : std_logic_vector) return t_Add1;
  function to_slv(x : t_Add1) return std_logic_vector;
  constant C_Sum_REG_ADDR: unsigned := x"00000004";
  subtype t_Sum is std_logic_vector(20 downto 0);
  constant C_Add_Stream0_REG_ADDR: unsigned := x"00000005";
  type t_Add_Stream0 is record
    A:std_logic_vector(19 downto 0);
    B:std_logic_vector(9 downto 0);
  end record;
  
  function to_Add_Stream0(x : std_logic_vector) return t_Add_Stream0;
  function to_slv(x : t_Add_Stream0) return std_logic_vector;
  constant C_Add_Stream1_REG_ADDR: unsigned := x"00000006";
  type t_Add_Stream1 is record
    C:std_logic_vector(7 downto 0);
  end record;
  
  function to_Add_Stream1(x : std_logic_vector) return t_Add_Stream1;
  function to_slv(x : t_Add_Stream1) return std_logic_vector;
  constant C_Sum_Stream_REG_ADDR: unsigned := x"00000007";
  subtype t_Sum_Stream is std_logic_vector(20 downto 0);




end Subblock_t_pkg;

package body Subblock_t_pkg is
  function to_Add0(x : std_logic_vector) return t_Add0 is
    variable res : t_Add0;
  begin
    res.A := std_logic_vector(x(19 downto 0));
    res.B := std_logic_vector(x(29 downto 20));
    return res;
  end function;
  
  function to_slv(x : t_Add0) return std_logic_vector is
    variable res : std_logic_vector(29 downto 0);
  begin
    res(19 downto 0) := std_logic_vector(x.A);
    res(29 downto 20) := std_logic_vector(x.B);
    return res;
  end function;
  
  function to_Add1(x : std_logic_vector) return t_Add1 is
    variable res : t_Add1;
  begin
    res.C := std_logic_vector(x(7 downto 0));
    return res;
  end function;
  
  function to_slv(x : t_Add1) return std_logic_vector is
    variable res : std_logic_vector(7 downto 0);
  begin
    res(7 downto 0) := std_logic_vector(x.C);
    return res;
  end function;
  
  function to_Add_Stream0(x : std_logic_vector) return t_Add_Stream0 is
    variable res : t_Add_Stream0;
  begin
    res.A := std_logic_vector(x(19 downto 0));
    res.B := std_logic_vector(x(29 downto 20));
    return res;
  end function;
  
  function to_slv(x : t_Add_Stream0) return std_logic_vector is
    variable res : std_logic_vector(29 downto 0);
  begin
    res(19 downto 0) := std_logic_vector(x.A);
    res(29 downto 20) := std_logic_vector(x.B);
    return res;
  end function;
  
  function to_Add_Stream1(x : std_logic_vector) return t_Add_Stream1 is
    variable res : t_Add_Stream1;
  begin
    res.C := std_logic_vector(x(7 downto 0));
    return res;
  end function;
  
  function to_slv(x : t_Add_Stream1) return std_logic_vector is
    variable res : std_logic_vector(7 downto 0);
  begin
    res(7 downto 0) := std_logic_vector(x.C);
    return res;
  end function;
  

end Subblock_t_pkg;
