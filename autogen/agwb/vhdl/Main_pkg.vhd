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

package Main_pkg is

  constant C_Main_ADDR_BITS : integer := 6;

  constant c_Main_ver_id : std_logic_vector(31 downto 0) := x"6a3f1bcd";
  constant v_Main_ver_id : t_ver_id_variants(0 downto 0) := (0 => x"6a3f1bcd");
  constant c_C1_size : integer := 1;
  constant c_C2_size : integer := 1;
  constant c_C3_size : integer := 1;
  constant c_S1_size : integer := 1;
  constant c_S2_size : integer := 1;
  constant c_S3_size : integer := 1;
  constant c_CA4_size : integer := 2;
  constant c_CA2_size : integer := 1;
  constant c_SA4_size : integer := 2;
  constant c_SA2_size : integer := 1;
  constant c_Counter0_size : integer := 1;
  constant c_Counter1_size : integer := 1;
  constant c_Mask_size : integer := 1;
  constant c_Version_size : integer := 1;
  constant c_Subblock_size : integer := 1;


  constant C_C1_REG_ADDR: unsigned := x"00000002";
  subtype t_C1 is std_logic_vector(6 downto 0);
  constant C_C2_REG_ADDR: unsigned := x"00000003";
  subtype t_C2 is std_logic_vector(8 downto 0);
  constant C_C3_REG_ADDR: unsigned := x"00000004";
  subtype t_C3 is std_logic_vector(11 downto 0);
  constant C_S1_REG_ADDR: unsigned := x"00000005";
  subtype t_S1 is std_logic_vector(6 downto 0);
  constant C_S2_REG_ADDR: unsigned := x"00000006";
  subtype t_S2 is std_logic_vector(8 downto 0);
  constant C_S3_REG_ADDR: unsigned := x"00000007";
  subtype t_S3 is std_logic_vector(11 downto 0);
  constant C_CA4_REG_ADDR: unsigned := x"00000008";
  type t_CA4 is record
    Item0:std_logic_vector(7 downto 0);
    Item1:std_logic_vector(7 downto 0);
    Item2:std_logic_vector(7 downto 0);
    Item3:std_logic_vector(7 downto 0);
  end record;
  
  function to_CA4(x : std_logic_vector) return t_CA4;
  function to_slv(x : t_CA4) return std_logic_vector;
  type ut_CA4_array is array( natural range <> ) of t_CA4;
  subtype t_CA4_array is ut_CA4_array(c_CA4_size - 1 downto 0);
  constant C_CA2_REG_ADDR: unsigned := x"0000000a";
  type t_CA2 is record
    Item0:std_logic_vector(7 downto 0);
    Item1:std_logic_vector(7 downto 0);
  end record;
  
  function to_CA2(x : std_logic_vector) return t_CA2;
  function to_slv(x : t_CA2) return std_logic_vector;
  constant C_SA4_REG_ADDR: unsigned := x"0000000b";
  type t_SA4 is record
    Item0:std_logic_vector(7 downto 0);
    Item1:std_logic_vector(7 downto 0);
    Item2:std_logic_vector(7 downto 0);
    Item3:std_logic_vector(7 downto 0);
  end record;
  
  function to_SA4(x : std_logic_vector) return t_SA4;
  function to_slv(x : t_SA4) return std_logic_vector;
  type ut_SA4_array is array( natural range <> ) of t_SA4;
  subtype t_SA4_array is ut_SA4_array(c_SA4_size - 1 downto 0);
  constant C_SA2_REG_ADDR: unsigned := x"0000000d";
  type t_SA2 is record
    Item0:std_logic_vector(7 downto 0);
    Item1:std_logic_vector(7 downto 0);
  end record;
  
  function to_SA2(x : std_logic_vector) return t_SA2;
  function to_slv(x : t_SA2) return std_logic_vector;
  constant C_Counter0_REG_ADDR: unsigned := x"0000000e";
  subtype t_Counter0 is std_logic_vector(31 downto 0);
  constant C_Counter1_REG_ADDR: unsigned := x"0000000f";
  subtype t_Counter1 is std_logic_vector(0 downto 0);
  constant C_Mask_REG_ADDR: unsigned := x"00000010";
  subtype t_Mask is std_logic_vector(15 downto 0);
  constant C_Version_REG_ADDR: unsigned := x"00000011";
  subtype t_Version is std_logic_vector(23 downto 0);




end Main_pkg;

package body Main_pkg is
  function to_CA4(x : std_logic_vector) return t_CA4 is
    variable res : t_CA4;
  begin
    res.Item0 := std_logic_vector(x(7 downto 0));
    res.Item1 := std_logic_vector(x(15 downto 8));
    res.Item2 := std_logic_vector(x(23 downto 16));
    res.Item3 := std_logic_vector(x(31 downto 24));
    return res;
  end function;
  
  function to_slv(x : t_CA4) return std_logic_vector is
    variable res : std_logic_vector(31 downto 0);
  begin
    res(7 downto 0) := std_logic_vector(x.Item0);
    res(15 downto 8) := std_logic_vector(x.Item1);
    res(23 downto 16) := std_logic_vector(x.Item2);
    res(31 downto 24) := std_logic_vector(x.Item3);
    return res;
  end function;
  
  function to_CA2(x : std_logic_vector) return t_CA2 is
    variable res : t_CA2;
  begin
    res.Item0 := std_logic_vector(x(7 downto 0));
    res.Item1 := std_logic_vector(x(15 downto 8));
    return res;
  end function;
  
  function to_slv(x : t_CA2) return std_logic_vector is
    variable res : std_logic_vector(15 downto 0);
  begin
    res(7 downto 0) := std_logic_vector(x.Item0);
    res(15 downto 8) := std_logic_vector(x.Item1);
    return res;
  end function;
  
  function to_SA4(x : std_logic_vector) return t_SA4 is
    variable res : t_SA4;
  begin
    res.Item0 := std_logic_vector(x(7 downto 0));
    res.Item1 := std_logic_vector(x(15 downto 8));
    res.Item2 := std_logic_vector(x(23 downto 16));
    res.Item3 := std_logic_vector(x(31 downto 24));
    return res;
  end function;
  
  function to_slv(x : t_SA4) return std_logic_vector is
    variable res : std_logic_vector(31 downto 0);
  begin
    res(7 downto 0) := std_logic_vector(x.Item0);
    res(15 downto 8) := std_logic_vector(x.Item1);
    res(23 downto 16) := std_logic_vector(x.Item2);
    res(31 downto 24) := std_logic_vector(x.Item3);
    return res;
  end function;
  
  function to_SA2(x : std_logic_vector) return t_SA2 is
    variable res : t_SA2;
  begin
    res.Item0 := std_logic_vector(x(7 downto 0));
    res.Item1 := std_logic_vector(x(15 downto 8));
    return res;
  end function;
  
  function to_slv(x : t_SA2) return std_logic_vector is
    variable res : std_logic_vector(15 downto 0);
  begin
    res(7 downto 0) := std_logic_vector(x.Item0);
    res(15 downto 8) := std_logic_vector(x.Item1);
    return res;
  end function;
  

end Main_pkg;
