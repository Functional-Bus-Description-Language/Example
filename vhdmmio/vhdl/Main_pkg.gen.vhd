-- Generated using vhdMMIO 0.0.3 (https://github.com/abs-tudelft/vhdmmio)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library work;
use work.vhdmmio_pkg.all;

package Main_pkg is

  -- Types used by the register file interface.
  type Main_f_C1_o_type is record
    data : std_logic_vector(6 downto 0);
  end record;
  constant MAIN_F_C1_O_RESET : Main_f_C1_o_type := (
    data => (others => '0')
  );
  type Main_f_C2_o_type is record
    data : std_logic_vector(8 downto 0);
  end record;
  constant MAIN_F_C2_O_RESET : Main_f_C2_o_type := (
    data => (others => '0')
  );
  type Main_f_C3_o_type is record
    data : std_logic_vector(11 downto 0);
  end record;
  constant MAIN_F_C3_O_RESET : Main_f_C3_o_type := (
    data => (others => '0')
  );
  type Main_f_S1_i_type is record
    write_data : std_logic_vector(6 downto 0);
  end record;
  constant MAIN_F_S1_I_RESET : Main_f_S1_i_type := (
    write_data => (others => '0')
  );
  type Main_f_S2_i_type is record
    write_data : std_logic_vector(8 downto 0);
  end record;
  constant MAIN_F_S2_I_RESET : Main_f_S2_i_type := (
    write_data => (others => '0')
  );
  type Main_f_S3_i_type is record
    write_data : std_logic_vector(11 downto 0);
  end record;
  constant MAIN_F_S3_I_RESET : Main_f_S3_i_type := (
    write_data => (others => '0')
  );
  type Main_f_CA_o_type is record
    data : std_logic_vector(7 downto 0);
  end record;
  constant MAIN_F_CA_O_RESET : Main_f_CA_o_type := (
    data => (others => '0')
  );
  type Main_f_CA_o_array is array (natural range <>) of Main_f_CA_o_type;
  type Main_f_SA_i_type is record
    write_data : std_logic_vector(7 downto 0);
  end record;
  constant MAIN_F_SA_I_RESET : Main_f_SA_i_type := (
    write_data => (others => '0')
  );
  type Main_f_SA_i_array is array (natural range <>) of Main_f_SA_i_type;
  type Main_f_Counter_i_type is record
    write_data : std_logic_vector(33 downto 0);
  end record;
  constant MAIN_F_COUNTER_I_RESET : Main_f_Counter_i_type := (
    write_data => (others => '0')
  );

  -- Component declaration for Main.
  component Main is
    port (

      -- Clock sensitive to the rising edge and synchronous, active-high reset.
      clk : in std_logic;
      reset : in std_logic := '0';

      -- Interface for field C1: C1.
      f_C1_o : out Main_f_C1_o_type := MAIN_F_C1_O_RESET;

      -- Interface for field C2: C2.
      f_C2_o : out Main_f_C2_o_type := MAIN_F_C2_O_RESET;

      -- Interface for field C3: C3.
      f_C3_o : out Main_f_C3_o_type := MAIN_F_C3_O_RESET;

      -- Interface for field S1: S1.
      f_S1_i : in Main_f_S1_i_type := MAIN_F_S1_I_RESET;

      -- Interface for field S2: S2.
      f_S2_i : in Main_f_S2_i_type := MAIN_F_S2_I_RESET;

      -- Interface for field S3: S3.
      f_S3_i : in Main_f_S3_i_type := MAIN_F_S3_I_RESET;

      -- Interface for field group CA: CA.
      f_CA_o : out Main_f_CA_o_array(0 to 9) := (others => MAIN_F_CA_O_RESET);

      -- Interface for field group SA: SA.
      f_SA_i : in Main_f_SA_i_array(0 to 9) := (others => MAIN_F_SA_I_RESET);

      -- Interface for field Counter: Counter.
      f_Counter_i : in Main_f_Counter_i_type := MAIN_F_COUNTER_I_RESET;

      -- AXI4-lite + interrupt request bus to the master.
      bus_i : in  axi4l32_m2s_type := AXI4L32_M2S_RESET;
      bus_o : out axi4l32_s2m_type := AXI4L32_S2M_RESET

    );
  end component;

end package Main_pkg;
