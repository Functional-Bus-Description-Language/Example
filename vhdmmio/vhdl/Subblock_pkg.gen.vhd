-- Generated using vhdMMIO 0.0.3 (https://github.com/abs-tudelft/vhdmmio)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library work;
use work.vhdmmio_pkg.all;

package Subblock_pkg is

  -- Types used by the register file interface.
  type Subblock_f_A_o_type is record
    data : std_logic_vector(19 downto 0);
  end record;
  constant SUBBLOCK_F_A_O_RESET : Subblock_f_A_o_type := (
    data => (others => '0')
  );
  type Subblock_f_B_o_type is record
    data : std_logic_vector(9 downto 0);
  end record;
  constant SUBBLOCK_F_B_O_RESET : Subblock_f_B_o_type := (
    data => (others => '0')
  );
  type Subblock_f_C_o_type is record
    data : std_logic_vector(7 downto 0);
  end record;
  constant SUBBLOCK_F_C_O_RESET : Subblock_f_C_o_type := (
    data => (others => '0')
  );
  type Subblock_f_AddStb_o_type is record
    data : std_logic_vector(31 downto 0);
  end record;
  constant SUBBLOCK_F_ADDSTB_O_RESET : Subblock_f_AddStb_o_type := (
    data => (others => '0')
  );
  type Subblock_f_Sum_i_type is record
    write_data : std_logic_vector(20 downto 0);
  end record;
  constant SUBBLOCK_F_SUM_I_RESET : Subblock_f_Sum_i_type := (
    write_data => (others => '0')
  );
  type Subblock_f_AS_o_type is record
    valid : std_logic;
    data : std_logic_vector(19 downto 0);
  end record;
  constant SUBBLOCK_F_AS_O_RESET : Subblock_f_AS_o_type := (
    valid => '0',
    data => (others => '0')
  );
  type Subblock_f_AS_i_type is record
    ready : std_logic;
  end record;
  constant SUBBLOCK_F_AS_I_RESET : Subblock_f_AS_i_type := (
    ready => '0'
  );
  type Subblock_f_BS_o_type is record
    valid : std_logic;
    data : std_logic_vector(9 downto 0);
  end record;
  constant SUBBLOCK_F_BS_O_RESET : Subblock_f_BS_o_type := (
    valid => '0',
    data => (others => '0')
  );
  type Subblock_f_BS_i_type is record
    ready : std_logic;
  end record;
  constant SUBBLOCK_F_BS_I_RESET : Subblock_f_BS_i_type := (
    ready => '0'
  );
  type Subblock_f_CS_o_type is record
    valid : std_logic;
    data : std_logic_vector(7 downto 0);
  end record;
  constant SUBBLOCK_F_CS_O_RESET : Subblock_f_CS_o_type := (
    valid => '0',
    data => (others => '0')
  );
  type Subblock_f_CS_i_type is record
    ready : std_logic;
  end record;
  constant SUBBLOCK_F_CS_I_RESET : Subblock_f_CS_i_type := (
    ready => '0'
  );
  type Subblock_f_Sum_Stream_i_type is record
    valid : std_logic;
    data : std_logic_vector(20 downto 0);
  end record;
  constant SUBBLOCK_F_SUM_STREAM_I_RESET : Subblock_f_Sum_Stream_i_type := (
    valid => '0',
    data => (others => '0')
  );
  type Subblock_f_Sum_Stream_o_type is record
    ready : std_logic;
  end record;
  constant SUBBLOCK_F_SUM_STREAM_O_RESET : Subblock_f_Sum_Stream_o_type := (
    ready => '0'
  );

  -- Component declaration for Subblock.
  component Subblock is
    port (

      -- Clock sensitive to the rising edge and synchronous, active-high reset.
      clk : in std_logic;
      reset : in std_logic := '0';

      -- Interface for field A: A.
      f_A_o : out Subblock_f_A_o_type := SUBBLOCK_F_A_O_RESET;

      -- Interface for field B: B.
      f_B_o : out Subblock_f_B_o_type := SUBBLOCK_F_B_O_RESET;

      -- Interface for field C: C.
      f_C_o : out Subblock_f_C_o_type := SUBBLOCK_F_C_O_RESET;

      -- Interface for field AddStb: AddStb.
      f_AddStb_o : out Subblock_f_AddStb_o_type := SUBBLOCK_F_ADDSTB_O_RESET;

      -- Interface for field Sum: Sum.
      f_Sum_i : in Subblock_f_Sum_i_type := SUBBLOCK_F_SUM_I_RESET;

      -- Interface for field AS: AS.
      f_AS_o : out Subblock_f_AS_o_type := SUBBLOCK_F_AS_O_RESET;
      f_AS_i : in Subblock_f_AS_i_type := SUBBLOCK_F_AS_I_RESET;

      -- Interface for field BS: BS.
      f_BS_o : out Subblock_f_BS_o_type := SUBBLOCK_F_BS_O_RESET;
      f_BS_i : in Subblock_f_BS_i_type := SUBBLOCK_F_BS_I_RESET;

      -- Interface for field CS: CS.
      f_CS_o : out Subblock_f_CS_o_type := SUBBLOCK_F_CS_O_RESET;
      f_CS_i : in Subblock_f_CS_i_type := SUBBLOCK_F_CS_I_RESET;

      -- Interface for field Sum_Stream: Sum_Stream.
      f_Sum_Stream_i : in Subblock_f_Sum_Stream_i_type
          := SUBBLOCK_F_SUM_STREAM_I_RESET;
      f_Sum_Stream_o : out Subblock_f_Sum_Stream_o_type
          := SUBBLOCK_F_SUM_STREAM_O_RESET;

      -- AXI4-lite + interrupt request bus to the master.
      bus_i : in  axi4l32_m2s_type := AXI4L32_M2S_RESET;
      bus_o : out axi4l32_s2m_type := AXI4L32_S2M_RESET

    );
  end component;

end package Subblock_pkg;
