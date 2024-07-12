library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.rggen_rtl.all;

entity Main is
  generic (
    ADDRESS_WIDTH: positive := 8;
    PRE_DECODE: boolean := false;
    BASE_ADDRESS: unsigned := x"0";
    ERROR_STATUS: boolean := false;
    INSERT_SLICER: boolean := false
  );
  port (
    i_clk: in std_logic;
    i_rst_n: in std_logic;
    i_psel: in std_logic;
    i_penable: in std_logic;
    i_paddr: in std_logic_vector(ADDRESS_WIDTH-1 downto 0);
    i_pprot: in std_logic_vector(2 downto 0);
    i_pwrite: in std_logic;
    i_pstrb: in std_logic_vector(3 downto 0);
    i_pwdata: in std_logic_vector(31 downto 0);
    o_pready: out std_logic;
    o_prdata: out std_logic_vector(31 downto 0);
    o_pslverr: out std_logic;
    o_Subblock_Add_A: out std_logic_vector(19 downto 0);
    o_Subblock_Add_B: out std_logic_vector(9 downto 0);
    o_Subblock_Add_C: out std_logic_vector(7 downto 0);
    o_Subblock_Add_C_write_trigger: out std_logic_vector(0 downto 0);
    i_Subblock_Add_Sum: in std_logic_vector(20 downto 0);
    i_Subblock_Sum_Stream_Sum: in std_logic_vector(20 downto 0);
    o_Subblock_Sum_Stream_Sum_read_trigger: out std_logic_vector(0 downto 0);
    o_C1_C1: out std_logic_vector(6 downto 0);
    o_C2_C2: out std_logic_vector(8 downto 0);
    o_C3_C3: out std_logic_vector(11 downto 0);
    i_S1_S1: in std_logic_vector(6 downto 0);
    i_S2_S2: in std_logic_vector(8 downto 0);
    i_S3_S3: in std_logic_vector(11 downto 0);
    o_CA_C: out std_logic_vector(79 downto 0);
    i_SA_S: in std_logic_vector(79 downto 0);
    i_Counter_Value: in std_logic_vector(32 downto 0);
    o_Mask_Mask: out std_logic_vector(15 downto 0)
  );
end Main;

architecture rtl of Main is
  signal register_valid: std_logic;
  signal register_access: std_logic_vector(1 downto 0);
  signal register_address: std_logic_vector(7 downto 0);
  signal register_write_data: std_logic_vector(31 downto 0);
  signal register_strobe: std_logic_vector(31 downto 0);
  signal register_active: std_logic_vector(30 downto 0);
  signal register_ready: std_logic_vector(30 downto 0);
  signal register_status: std_logic_vector(61 downto 0);
  signal register_read_data: std_logic_vector(991 downto 0);
  signal register_value: std_logic_vector(1983 downto 0);
begin
  u_adapter: entity work.rggen_apb_adaper
    generic map (
      ADDRESS_WIDTH       => ADDRESS_WIDTH,
      LOCAL_ADDRESS_WIDTH => 8,
      BUS_WIDTH           => 32,
      REGISTERS           => 31,
      PRE_DECODE          => PRE_DECODE,
      BASE_ADDRESS        => BASE_ADDRESS,
      BYTE_SIZE           => 256,
      ERROR_STATUS        => ERROR_STATUS,
      INSERT_SLICER       => INSERT_SLICER
    )
    port map (
      i_clk                 => i_clk,
      i_rst_n               => i_rst_n,
      i_psel                => i_psel,
      i_penable             => i_penable,
      i_paddr               => i_paddr,
      i_pprot               => i_pprot,
      i_pwrite              => i_pwrite,
      i_pstrb               => i_pstrb,
      i_pwdata              => i_pwdata,
      o_pready              => o_pready,
      o_prdata              => o_prdata,
      o_pslverr             => o_pslverr,
      o_register_valid      => register_valid,
      o_register_access     => register_access,
      o_register_address    => register_address,
      o_register_write_data => register_write_data,
      o_register_strobe     => register_strobe,
      i_register_active     => register_active,
      i_register_ready      => register_ready,
      i_register_status     => register_status,
      i_register_read_data  => register_read_data
    );
  g_Subblock: block
  begin
    g_Add: block
      signal bit_field_valid: std_logic;
      signal bit_field_read_mask: std_logic_vector(63 downto 0);
      signal bit_field_write_mask: std_logic_vector(63 downto 0);
      signal bit_field_write_data: std_logic_vector(63 downto 0);
      signal bit_field_read_data: std_logic_vector(63 downto 0);
      signal bit_field_value: std_logic_vector(63 downto 0);
    begin
      \g_tie_off\: for \__i\ in 0 to 63 generate
        g: if (bit_slice(x"07ffffffffffffff", \__i\) = '0') generate
          bit_field_read_data(\__i\) <= '0';
          bit_field_value(\__i\) <= '0';
        end generate;
      end generate;
      u_register: entity work.rggen_default_register
        generic map (
          READABLE        => true,
          WRITABLE        => true,
          ADDRESS_WIDTH   => 8,
          OFFSET_ADDRESS  => x"00",
          BUS_WIDTH       => 32,
          DATA_WIDTH      => 64
        )
        port map (
          i_clk                   => i_clk,
          i_rst_n                 => i_rst_n,
          i_register_valid        => register_valid,
          i_register_access       => register_access,
          i_register_address      => register_address,
          i_register_write_data   => register_write_data,
          i_register_strobe       => register_strobe,
          o_register_active       => register_active(0),
          o_register_ready        => register_ready(0),
          o_register_status       => register_status(1 downto 0),
          o_register_read_data    => register_read_data(31 downto 0),
          o_register_value        => register_value(63 downto 0),
          o_bit_field_valid       => bit_field_valid,
          o_bit_field_read_mask   => bit_field_read_mask,
          o_bit_field_write_mask  => bit_field_write_mask,
          o_bit_field_write_data  => bit_field_write_data,
          i_bit_field_read_data   => bit_field_read_data,
          i_bit_field_value       => bit_field_value
        );
      g_A: block
      begin
        u_bit_field: entity work.rggen_bit_field
          generic map (
            WIDTH           => 20,
            INITIAL_VALUE   => slice(x"00000", 20, 0),
            SW_READ_ACTION  => RGGEN_READ_NONE,
            SW_WRITE_ONCE   => false,
            TRIGGER         => false
          )
          port map (
            i_clk             => i_clk,
            i_rst_n           => i_rst_n,
            i_sw_valid        => bit_field_valid,
            i_sw_read_mask    => bit_field_read_mask(19 downto 0),
            i_sw_write_enable => "1",
            i_sw_write_mask   => bit_field_write_mask(19 downto 0),
            i_sw_write_data   => bit_field_write_data(19 downto 0),
            o_sw_read_data    => bit_field_read_data(19 downto 0),
            o_sw_value        => bit_field_value(19 downto 0),
            o_write_trigger   => open,
            o_read_trigger    => open,
            i_hw_write_enable => "0",
            i_hw_write_data   => (others => '0'),
            i_hw_set          => (others => '0'),
            i_hw_clear        => (others => '0'),
            i_value           => (others => '0'),
            i_mask            => (others => '1'),
            o_value           => o_Subblock_Add_A,
            o_value_unmasked  => open
          );
      end block;
      g_B: block
      begin
        u_bit_field: entity work.rggen_bit_field
          generic map (
            WIDTH           => 10,
            INITIAL_VALUE   => slice(x"000", 10, 0),
            SW_READ_ACTION  => RGGEN_READ_NONE,
            SW_WRITE_ONCE   => false,
            TRIGGER         => false
          )
          port map (
            i_clk             => i_clk,
            i_rst_n           => i_rst_n,
            i_sw_valid        => bit_field_valid,
            i_sw_read_mask    => bit_field_read_mask(29 downto 20),
            i_sw_write_enable => "1",
            i_sw_write_mask   => bit_field_write_mask(29 downto 20),
            i_sw_write_data   => bit_field_write_data(29 downto 20),
            o_sw_read_data    => bit_field_read_data(29 downto 20),
            o_sw_value        => bit_field_value(29 downto 20),
            o_write_trigger   => open,
            o_read_trigger    => open,
            i_hw_write_enable => "0",
            i_hw_write_data   => (others => '0'),
            i_hw_set          => (others => '0'),
            i_hw_clear        => (others => '0'),
            i_value           => (others => '0'),
            i_mask            => (others => '1'),
            o_value           => o_Subblock_Add_B,
            o_value_unmasked  => open
          );
      end block;
      g_C: block
      begin
        u_bit_field: entity work.rggen_bit_field
          generic map (
            WIDTH           => 8,
            INITIAL_VALUE   => slice(x"00", 8, 0),
            SW_READ_ACTION  => RGGEN_READ_NONE,
            SW_WRITE_ONCE   => false,
            TRIGGER         => true
          )
          port map (
            i_clk             => i_clk,
            i_rst_n           => i_rst_n,
            i_sw_valid        => bit_field_valid,
            i_sw_read_mask    => bit_field_read_mask(37 downto 30),
            i_sw_write_enable => "1",
            i_sw_write_mask   => bit_field_write_mask(37 downto 30),
            i_sw_write_data   => bit_field_write_data(37 downto 30),
            o_sw_read_data    => bit_field_read_data(37 downto 30),
            o_sw_value        => bit_field_value(37 downto 30),
            o_write_trigger   => o_Subblock_Add_C_write_trigger,
            o_read_trigger    => open,
            i_hw_write_enable => "0",
            i_hw_write_data   => (others => '0'),
            i_hw_set          => (others => '0'),
            i_hw_clear        => (others => '0'),
            i_value           => (others => '0'),
            i_mask            => (others => '1'),
            o_value           => o_Subblock_Add_C,
            o_value_unmasked  => open
          );
      end block;
      g_Sum: block
      begin
        u_bit_field: entity work.rggen_bit_field
          generic map (
            WIDTH               => 21,
            STORAGE             => false,
            EXTERNAL_READ_DATA  => true,
            TRIGGER             => false
          )
          port map (
            i_clk             => i_clk,
            i_rst_n           => i_rst_n,
            i_sw_valid        => bit_field_valid,
            i_sw_read_mask    => bit_field_read_mask(58 downto 38),
            i_sw_write_enable => "0",
            i_sw_write_mask   => bit_field_write_mask(58 downto 38),
            i_sw_write_data   => bit_field_write_data(58 downto 38),
            o_sw_read_data    => bit_field_read_data(58 downto 38),
            o_sw_value        => bit_field_value(58 downto 38),
            o_write_trigger   => open,
            o_read_trigger    => open,
            i_hw_write_enable => "0",
            i_hw_write_data   => (others => '0'),
            i_hw_set          => (others => '0'),
            i_hw_clear        => (others => '0'),
            i_value           => i_Subblock_Add_Sum,
            i_mask            => (others => '1'),
            o_value           => open,
            o_value_unmasked  => open
          );
      end block;
    end block;
    g_Sum_Stream: block
      signal bit_field_valid: std_logic;
      signal bit_field_read_mask: std_logic_vector(31 downto 0);
      signal bit_field_write_mask: std_logic_vector(31 downto 0);
      signal bit_field_write_data: std_logic_vector(31 downto 0);
      signal bit_field_read_data: std_logic_vector(31 downto 0);
      signal bit_field_value: std_logic_vector(31 downto 0);
    begin
      \g_tie_off\: for \__i\ in 0 to 31 generate
        g: if (bit_slice(x"001fffff", \__i\) = '0') generate
          bit_field_read_data(\__i\) <= '0';
          bit_field_value(\__i\) <= '0';
        end generate;
      end generate;
      u_register: entity work.rggen_default_register
        generic map (
          READABLE        => true,
          WRITABLE        => false,
          ADDRESS_WIDTH   => 8,
          OFFSET_ADDRESS  => x"08",
          BUS_WIDTH       => 32,
          DATA_WIDTH      => 32
        )
        port map (
          i_clk                   => i_clk,
          i_rst_n                 => i_rst_n,
          i_register_valid        => register_valid,
          i_register_access       => register_access,
          i_register_address      => register_address,
          i_register_write_data   => register_write_data,
          i_register_strobe       => register_strobe,
          o_register_active       => register_active(1),
          o_register_ready        => register_ready(1),
          o_register_status       => register_status(3 downto 2),
          o_register_read_data    => register_read_data(63 downto 32),
          o_register_value        => register_value(95 downto 64),
          o_bit_field_valid       => bit_field_valid,
          o_bit_field_read_mask   => bit_field_read_mask,
          o_bit_field_write_mask  => bit_field_write_mask,
          o_bit_field_write_data  => bit_field_write_data,
          i_bit_field_read_data   => bit_field_read_data,
          i_bit_field_value       => bit_field_value
        );
      g_Sum: block
      begin
        u_bit_field: entity work.rggen_bit_field
          generic map (
            WIDTH               => 21,
            STORAGE             => false,
            EXTERNAL_READ_DATA  => true,
            TRIGGER             => true
          )
          port map (
            i_clk             => i_clk,
            i_rst_n           => i_rst_n,
            i_sw_valid        => bit_field_valid,
            i_sw_read_mask    => bit_field_read_mask(20 downto 0),
            i_sw_write_enable => "0",
            i_sw_write_mask   => bit_field_write_mask(20 downto 0),
            i_sw_write_data   => bit_field_write_data(20 downto 0),
            o_sw_read_data    => bit_field_read_data(20 downto 0),
            o_sw_value        => bit_field_value(20 downto 0),
            o_write_trigger   => open,
            o_read_trigger    => o_Subblock_Sum_Stream_Sum_read_trigger,
            i_hw_write_enable => "0",
            i_hw_write_data   => (others => '0'),
            i_hw_set          => (others => '0'),
            i_hw_clear        => (others => '0'),
            i_value           => i_Subblock_Sum_Stream_Sum,
            i_mask            => (others => '1'),
            o_value           => open,
            o_value_unmasked  => open
          );
      end block;
    end block;
  end block;
  g_C1: block
    signal bit_field_valid: std_logic;
    signal bit_field_read_mask: std_logic_vector(31 downto 0);
    signal bit_field_write_mask: std_logic_vector(31 downto 0);
    signal bit_field_write_data: std_logic_vector(31 downto 0);
    signal bit_field_read_data: std_logic_vector(31 downto 0);
    signal bit_field_value: std_logic_vector(31 downto 0);
  begin
    \g_tie_off\: for \__i\ in 0 to 31 generate
      g: if (bit_slice(x"0000007f", \__i\) = '0') generate
        bit_field_read_data(\__i\) <= '0';
        bit_field_value(\__i\) <= '0';
      end generate;
    end generate;
    u_register: entity work.rggen_default_register
      generic map (
        READABLE        => true,
        WRITABLE        => true,
        ADDRESS_WIDTH   => 8,
        OFFSET_ADDRESS  => x"0c",
        BUS_WIDTH       => 32,
        DATA_WIDTH      => 32
      )
      port map (
        i_clk                   => i_clk,
        i_rst_n                 => i_rst_n,
        i_register_valid        => register_valid,
        i_register_access       => register_access,
        i_register_address      => register_address,
        i_register_write_data   => register_write_data,
        i_register_strobe       => register_strobe,
        o_register_active       => register_active(2),
        o_register_ready        => register_ready(2),
        o_register_status       => register_status(5 downto 4),
        o_register_read_data    => register_read_data(95 downto 64),
        o_register_value        => register_value(159 downto 128),
        o_bit_field_valid       => bit_field_valid,
        o_bit_field_read_mask   => bit_field_read_mask,
        o_bit_field_write_mask  => bit_field_write_mask,
        o_bit_field_write_data  => bit_field_write_data,
        i_bit_field_read_data   => bit_field_read_data,
        i_bit_field_value       => bit_field_value
      );
    g_C1: block
    begin
      u_bit_field: entity work.rggen_bit_field
        generic map (
          WIDTH           => 7,
          INITIAL_VALUE   => slice(x"00", 7, 0),
          SW_WRITE_ONCE   => false,
          TRIGGER         => false
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_valid        => bit_field_valid,
          i_sw_read_mask    => bit_field_read_mask(6 downto 0),
          i_sw_write_enable => "1",
          i_sw_write_mask   => bit_field_write_mask(6 downto 0),
          i_sw_write_data   => bit_field_write_data(6 downto 0),
          o_sw_read_data    => bit_field_read_data(6 downto 0),
          o_sw_value        => bit_field_value(6 downto 0),
          o_write_trigger   => open,
          o_read_trigger    => open,
          i_hw_write_enable => "0",
          i_hw_write_data   => (others => '0'),
          i_hw_set          => (others => '0'),
          i_hw_clear        => (others => '0'),
          i_value           => (others => '0'),
          i_mask            => (others => '1'),
          o_value           => o_C1_C1,
          o_value_unmasked  => open
        );
    end block;
  end block;
  g_C2: block
    signal bit_field_valid: std_logic;
    signal bit_field_read_mask: std_logic_vector(31 downto 0);
    signal bit_field_write_mask: std_logic_vector(31 downto 0);
    signal bit_field_write_data: std_logic_vector(31 downto 0);
    signal bit_field_read_data: std_logic_vector(31 downto 0);
    signal bit_field_value: std_logic_vector(31 downto 0);
  begin
    \g_tie_off\: for \__i\ in 0 to 31 generate
      g: if (bit_slice(x"000001ff", \__i\) = '0') generate
        bit_field_read_data(\__i\) <= '0';
        bit_field_value(\__i\) <= '0';
      end generate;
    end generate;
    u_register: entity work.rggen_default_register
      generic map (
        READABLE        => true,
        WRITABLE        => true,
        ADDRESS_WIDTH   => 8,
        OFFSET_ADDRESS  => x"10",
        BUS_WIDTH       => 32,
        DATA_WIDTH      => 32
      )
      port map (
        i_clk                   => i_clk,
        i_rst_n                 => i_rst_n,
        i_register_valid        => register_valid,
        i_register_access       => register_access,
        i_register_address      => register_address,
        i_register_write_data   => register_write_data,
        i_register_strobe       => register_strobe,
        o_register_active       => register_active(3),
        o_register_ready        => register_ready(3),
        o_register_status       => register_status(7 downto 6),
        o_register_read_data    => register_read_data(127 downto 96),
        o_register_value        => register_value(223 downto 192),
        o_bit_field_valid       => bit_field_valid,
        o_bit_field_read_mask   => bit_field_read_mask,
        o_bit_field_write_mask  => bit_field_write_mask,
        o_bit_field_write_data  => bit_field_write_data,
        i_bit_field_read_data   => bit_field_read_data,
        i_bit_field_value       => bit_field_value
      );
    g_C2: block
    begin
      u_bit_field: entity work.rggen_bit_field
        generic map (
          WIDTH           => 9,
          INITIAL_VALUE   => slice(x"000", 9, 0),
          SW_WRITE_ONCE   => false,
          TRIGGER         => false
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_valid        => bit_field_valid,
          i_sw_read_mask    => bit_field_read_mask(8 downto 0),
          i_sw_write_enable => "1",
          i_sw_write_mask   => bit_field_write_mask(8 downto 0),
          i_sw_write_data   => bit_field_write_data(8 downto 0),
          o_sw_read_data    => bit_field_read_data(8 downto 0),
          o_sw_value        => bit_field_value(8 downto 0),
          o_write_trigger   => open,
          o_read_trigger    => open,
          i_hw_write_enable => "0",
          i_hw_write_data   => (others => '0'),
          i_hw_set          => (others => '0'),
          i_hw_clear        => (others => '0'),
          i_value           => (others => '0'),
          i_mask            => (others => '1'),
          o_value           => o_C2_C2,
          o_value_unmasked  => open
        );
    end block;
  end block;
  g_C3: block
    signal bit_field_valid: std_logic;
    signal bit_field_read_mask: std_logic_vector(31 downto 0);
    signal bit_field_write_mask: std_logic_vector(31 downto 0);
    signal bit_field_write_data: std_logic_vector(31 downto 0);
    signal bit_field_read_data: std_logic_vector(31 downto 0);
    signal bit_field_value: std_logic_vector(31 downto 0);
  begin
    \g_tie_off\: for \__i\ in 0 to 31 generate
      g: if (bit_slice(x"00000fff", \__i\) = '0') generate
        bit_field_read_data(\__i\) <= '0';
        bit_field_value(\__i\) <= '0';
      end generate;
    end generate;
    u_register: entity work.rggen_default_register
      generic map (
        READABLE        => true,
        WRITABLE        => true,
        ADDRESS_WIDTH   => 8,
        OFFSET_ADDRESS  => x"14",
        BUS_WIDTH       => 32,
        DATA_WIDTH      => 32
      )
      port map (
        i_clk                   => i_clk,
        i_rst_n                 => i_rst_n,
        i_register_valid        => register_valid,
        i_register_access       => register_access,
        i_register_address      => register_address,
        i_register_write_data   => register_write_data,
        i_register_strobe       => register_strobe,
        o_register_active       => register_active(4),
        o_register_ready        => register_ready(4),
        o_register_status       => register_status(9 downto 8),
        o_register_read_data    => register_read_data(159 downto 128),
        o_register_value        => register_value(287 downto 256),
        o_bit_field_valid       => bit_field_valid,
        o_bit_field_read_mask   => bit_field_read_mask,
        o_bit_field_write_mask  => bit_field_write_mask,
        o_bit_field_write_data  => bit_field_write_data,
        i_bit_field_read_data   => bit_field_read_data,
        i_bit_field_value       => bit_field_value
      );
    g_C3: block
    begin
      u_bit_field: entity work.rggen_bit_field
        generic map (
          WIDTH           => 12,
          INITIAL_VALUE   => slice(x"000", 12, 0),
          SW_WRITE_ONCE   => false,
          TRIGGER         => false
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_valid        => bit_field_valid,
          i_sw_read_mask    => bit_field_read_mask(11 downto 0),
          i_sw_write_enable => "1",
          i_sw_write_mask   => bit_field_write_mask(11 downto 0),
          i_sw_write_data   => bit_field_write_data(11 downto 0),
          o_sw_read_data    => bit_field_read_data(11 downto 0),
          o_sw_value        => bit_field_value(11 downto 0),
          o_write_trigger   => open,
          o_read_trigger    => open,
          i_hw_write_enable => "0",
          i_hw_write_data   => (others => '0'),
          i_hw_set          => (others => '0'),
          i_hw_clear        => (others => '0'),
          i_value           => (others => '0'),
          i_mask            => (others => '1'),
          o_value           => o_C3_C3,
          o_value_unmasked  => open
        );
    end block;
  end block;
  g_S1: block
    signal bit_field_valid: std_logic;
    signal bit_field_read_mask: std_logic_vector(31 downto 0);
    signal bit_field_write_mask: std_logic_vector(31 downto 0);
    signal bit_field_write_data: std_logic_vector(31 downto 0);
    signal bit_field_read_data: std_logic_vector(31 downto 0);
    signal bit_field_value: std_logic_vector(31 downto 0);
  begin
    \g_tie_off\: for \__i\ in 0 to 31 generate
      g: if (bit_slice(x"0000007f", \__i\) = '0') generate
        bit_field_read_data(\__i\) <= '0';
        bit_field_value(\__i\) <= '0';
      end generate;
    end generate;
    u_register: entity work.rggen_default_register
      generic map (
        READABLE        => true,
        WRITABLE        => false,
        ADDRESS_WIDTH   => 8,
        OFFSET_ADDRESS  => x"18",
        BUS_WIDTH       => 32,
        DATA_WIDTH      => 32
      )
      port map (
        i_clk                   => i_clk,
        i_rst_n                 => i_rst_n,
        i_register_valid        => register_valid,
        i_register_access       => register_access,
        i_register_address      => register_address,
        i_register_write_data   => register_write_data,
        i_register_strobe       => register_strobe,
        o_register_active       => register_active(5),
        o_register_ready        => register_ready(5),
        o_register_status       => register_status(11 downto 10),
        o_register_read_data    => register_read_data(191 downto 160),
        o_register_value        => register_value(351 downto 320),
        o_bit_field_valid       => bit_field_valid,
        o_bit_field_read_mask   => bit_field_read_mask,
        o_bit_field_write_mask  => bit_field_write_mask,
        o_bit_field_write_data  => bit_field_write_data,
        i_bit_field_read_data   => bit_field_read_data,
        i_bit_field_value       => bit_field_value
      );
    g_S1: block
    begin
      u_bit_field: entity work.rggen_bit_field
        generic map (
          WIDTH               => 7,
          STORAGE             => false,
          EXTERNAL_READ_DATA  => true,
          TRIGGER             => false
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_valid        => bit_field_valid,
          i_sw_read_mask    => bit_field_read_mask(6 downto 0),
          i_sw_write_enable => "0",
          i_sw_write_mask   => bit_field_write_mask(6 downto 0),
          i_sw_write_data   => bit_field_write_data(6 downto 0),
          o_sw_read_data    => bit_field_read_data(6 downto 0),
          o_sw_value        => bit_field_value(6 downto 0),
          o_write_trigger   => open,
          o_read_trigger    => open,
          i_hw_write_enable => "0",
          i_hw_write_data   => (others => '0'),
          i_hw_set          => (others => '0'),
          i_hw_clear        => (others => '0'),
          i_value           => i_S1_S1,
          i_mask            => (others => '1'),
          o_value           => open,
          o_value_unmasked  => open
        );
    end block;
  end block;
  g_S2: block
    signal bit_field_valid: std_logic;
    signal bit_field_read_mask: std_logic_vector(31 downto 0);
    signal bit_field_write_mask: std_logic_vector(31 downto 0);
    signal bit_field_write_data: std_logic_vector(31 downto 0);
    signal bit_field_read_data: std_logic_vector(31 downto 0);
    signal bit_field_value: std_logic_vector(31 downto 0);
  begin
    \g_tie_off\: for \__i\ in 0 to 31 generate
      g: if (bit_slice(x"000001ff", \__i\) = '0') generate
        bit_field_read_data(\__i\) <= '0';
        bit_field_value(\__i\) <= '0';
      end generate;
    end generate;
    u_register: entity work.rggen_default_register
      generic map (
        READABLE        => true,
        WRITABLE        => false,
        ADDRESS_WIDTH   => 8,
        OFFSET_ADDRESS  => x"1c",
        BUS_WIDTH       => 32,
        DATA_WIDTH      => 32
      )
      port map (
        i_clk                   => i_clk,
        i_rst_n                 => i_rst_n,
        i_register_valid        => register_valid,
        i_register_access       => register_access,
        i_register_address      => register_address,
        i_register_write_data   => register_write_data,
        i_register_strobe       => register_strobe,
        o_register_active       => register_active(6),
        o_register_ready        => register_ready(6),
        o_register_status       => register_status(13 downto 12),
        o_register_read_data    => register_read_data(223 downto 192),
        o_register_value        => register_value(415 downto 384),
        o_bit_field_valid       => bit_field_valid,
        o_bit_field_read_mask   => bit_field_read_mask,
        o_bit_field_write_mask  => bit_field_write_mask,
        o_bit_field_write_data  => bit_field_write_data,
        i_bit_field_read_data   => bit_field_read_data,
        i_bit_field_value       => bit_field_value
      );
    g_S2: block
    begin
      u_bit_field: entity work.rggen_bit_field
        generic map (
          WIDTH               => 9,
          STORAGE             => false,
          EXTERNAL_READ_DATA  => true,
          TRIGGER             => false
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_valid        => bit_field_valid,
          i_sw_read_mask    => bit_field_read_mask(8 downto 0),
          i_sw_write_enable => "0",
          i_sw_write_mask   => bit_field_write_mask(8 downto 0),
          i_sw_write_data   => bit_field_write_data(8 downto 0),
          o_sw_read_data    => bit_field_read_data(8 downto 0),
          o_sw_value        => bit_field_value(8 downto 0),
          o_write_trigger   => open,
          o_read_trigger    => open,
          i_hw_write_enable => "0",
          i_hw_write_data   => (others => '0'),
          i_hw_set          => (others => '0'),
          i_hw_clear        => (others => '0'),
          i_value           => i_S2_S2,
          i_mask            => (others => '1'),
          o_value           => open,
          o_value_unmasked  => open
        );
    end block;
  end block;
  g_S3: block
    signal bit_field_valid: std_logic;
    signal bit_field_read_mask: std_logic_vector(31 downto 0);
    signal bit_field_write_mask: std_logic_vector(31 downto 0);
    signal bit_field_write_data: std_logic_vector(31 downto 0);
    signal bit_field_read_data: std_logic_vector(31 downto 0);
    signal bit_field_value: std_logic_vector(31 downto 0);
  begin
    \g_tie_off\: for \__i\ in 0 to 31 generate
      g: if (bit_slice(x"00000fff", \__i\) = '0') generate
        bit_field_read_data(\__i\) <= '0';
        bit_field_value(\__i\) <= '0';
      end generate;
    end generate;
    u_register: entity work.rggen_default_register
      generic map (
        READABLE        => true,
        WRITABLE        => false,
        ADDRESS_WIDTH   => 8,
        OFFSET_ADDRESS  => x"20",
        BUS_WIDTH       => 32,
        DATA_WIDTH      => 32
      )
      port map (
        i_clk                   => i_clk,
        i_rst_n                 => i_rst_n,
        i_register_valid        => register_valid,
        i_register_access       => register_access,
        i_register_address      => register_address,
        i_register_write_data   => register_write_data,
        i_register_strobe       => register_strobe,
        o_register_active       => register_active(7),
        o_register_ready        => register_ready(7),
        o_register_status       => register_status(15 downto 14),
        o_register_read_data    => register_read_data(255 downto 224),
        o_register_value        => register_value(479 downto 448),
        o_bit_field_valid       => bit_field_valid,
        o_bit_field_read_mask   => bit_field_read_mask,
        o_bit_field_write_mask  => bit_field_write_mask,
        o_bit_field_write_data  => bit_field_write_data,
        i_bit_field_read_data   => bit_field_read_data,
        i_bit_field_value       => bit_field_value
      );
    g_S3: block
    begin
      u_bit_field: entity work.rggen_bit_field
        generic map (
          WIDTH               => 12,
          STORAGE             => false,
          EXTERNAL_READ_DATA  => true,
          TRIGGER             => false
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_valid        => bit_field_valid,
          i_sw_read_mask    => bit_field_read_mask(11 downto 0),
          i_sw_write_enable => "0",
          i_sw_write_mask   => bit_field_write_mask(11 downto 0),
          i_sw_write_data   => bit_field_write_data(11 downto 0),
          o_sw_read_data    => bit_field_read_data(11 downto 0),
          o_sw_value        => bit_field_value(11 downto 0),
          o_write_trigger   => open,
          o_read_trigger    => open,
          i_hw_write_enable => "0",
          i_hw_write_data   => (others => '0'),
          i_hw_set          => (others => '0'),
          i_hw_clear        => (others => '0'),
          i_value           => i_S3_S3,
          i_mask            => (others => '1'),
          o_value           => open,
          o_value_unmasked  => open
        );
    end block;
  end block;
  g_CA: block
  begin
    g: for i in 0 to 9 generate
      signal bit_field_valid: std_logic;
      signal bit_field_read_mask: std_logic_vector(31 downto 0);
      signal bit_field_write_mask: std_logic_vector(31 downto 0);
      signal bit_field_write_data: std_logic_vector(31 downto 0);
      signal bit_field_read_data: std_logic_vector(31 downto 0);
      signal bit_field_value: std_logic_vector(31 downto 0);
    begin
      \g_tie_off\: for \__i\ in 0 to 31 generate
        g: if (bit_slice(x"000000ff", \__i\) = '0') generate
          bit_field_read_data(\__i\) <= '0';
          bit_field_value(\__i\) <= '0';
        end generate;
      end generate;
      u_register: entity work.rggen_default_register
        generic map (
          READABLE        => true,
          WRITABLE        => true,
          ADDRESS_WIDTH   => 8,
          OFFSET_ADDRESS  => x"24"+4*i,
          BUS_WIDTH       => 32,
          DATA_WIDTH      => 32
        )
        port map (
          i_clk                   => i_clk,
          i_rst_n                 => i_rst_n,
          i_register_valid        => register_valid,
          i_register_access       => register_access,
          i_register_address      => register_address,
          i_register_write_data   => register_write_data,
          i_register_strobe       => register_strobe,
          o_register_active       => register_active(8+i),
          o_register_ready        => register_ready(8+i),
          o_register_status       => register_status(2*(8+i)+1 downto 2*(8+i)),
          o_register_read_data    => register_read_data(32*(8+i)+31 downto 32*(8+i)),
          o_register_value        => register_value(64*(8+i)+0+31 downto 64*(8+i)+0),
          o_bit_field_valid       => bit_field_valid,
          o_bit_field_read_mask   => bit_field_read_mask,
          o_bit_field_write_mask  => bit_field_write_mask,
          o_bit_field_write_data  => bit_field_write_data,
          i_bit_field_read_data   => bit_field_read_data,
          i_bit_field_value       => bit_field_value
        );
      g_C: block
      begin
        u_bit_field: entity work.rggen_bit_field
          generic map (
            WIDTH           => 8,
            INITIAL_VALUE   => slice(x"00", 8, 0),
            SW_WRITE_ONCE   => false,
            TRIGGER         => false
          )
          port map (
            i_clk             => i_clk,
            i_rst_n           => i_rst_n,
            i_sw_valid        => bit_field_valid,
            i_sw_read_mask    => bit_field_read_mask(7 downto 0),
            i_sw_write_enable => "1",
            i_sw_write_mask   => bit_field_write_mask(7 downto 0),
            i_sw_write_data   => bit_field_write_data(7 downto 0),
            o_sw_read_data    => bit_field_read_data(7 downto 0),
            o_sw_value        => bit_field_value(7 downto 0),
            o_write_trigger   => open,
            o_read_trigger    => open,
            i_hw_write_enable => "0",
            i_hw_write_data   => (others => '0'),
            i_hw_set          => (others => '0'),
            i_hw_clear        => (others => '0'),
            i_value           => (others => '0'),
            i_mask            => (others => '1'),
            o_value           => o_CA_C(8*(i)+7 downto 8*(i)),
            o_value_unmasked  => open
          );
      end block;
    end generate;
  end block;
  g_SA: block
  begin
    g: for i in 0 to 9 generate
      signal bit_field_valid: std_logic;
      signal bit_field_read_mask: std_logic_vector(31 downto 0);
      signal bit_field_write_mask: std_logic_vector(31 downto 0);
      signal bit_field_write_data: std_logic_vector(31 downto 0);
      signal bit_field_read_data: std_logic_vector(31 downto 0);
      signal bit_field_value: std_logic_vector(31 downto 0);
    begin
      \g_tie_off\: for \__i\ in 0 to 31 generate
        g: if (bit_slice(x"000000ff", \__i\) = '0') generate
          bit_field_read_data(\__i\) <= '0';
          bit_field_value(\__i\) <= '0';
        end generate;
      end generate;
      u_register: entity work.rggen_default_register
        generic map (
          READABLE        => true,
          WRITABLE        => false,
          ADDRESS_WIDTH   => 8,
          OFFSET_ADDRESS  => x"4c"+4*i,
          BUS_WIDTH       => 32,
          DATA_WIDTH      => 32
        )
        port map (
          i_clk                   => i_clk,
          i_rst_n                 => i_rst_n,
          i_register_valid        => register_valid,
          i_register_access       => register_access,
          i_register_address      => register_address,
          i_register_write_data   => register_write_data,
          i_register_strobe       => register_strobe,
          o_register_active       => register_active(18+i),
          o_register_ready        => register_ready(18+i),
          o_register_status       => register_status(2*(18+i)+1 downto 2*(18+i)),
          o_register_read_data    => register_read_data(32*(18+i)+31 downto 32*(18+i)),
          o_register_value        => register_value(64*(18+i)+0+31 downto 64*(18+i)+0),
          o_bit_field_valid       => bit_field_valid,
          o_bit_field_read_mask   => bit_field_read_mask,
          o_bit_field_write_mask  => bit_field_write_mask,
          o_bit_field_write_data  => bit_field_write_data,
          i_bit_field_read_data   => bit_field_read_data,
          i_bit_field_value       => bit_field_value
        );
      g_S: block
      begin
        u_bit_field: entity work.rggen_bit_field
          generic map (
            WIDTH               => 8,
            STORAGE             => false,
            EXTERNAL_READ_DATA  => true,
            TRIGGER             => false
          )
          port map (
            i_clk             => i_clk,
            i_rst_n           => i_rst_n,
            i_sw_valid        => bit_field_valid,
            i_sw_read_mask    => bit_field_read_mask(7 downto 0),
            i_sw_write_enable => "0",
            i_sw_write_mask   => bit_field_write_mask(7 downto 0),
            i_sw_write_data   => bit_field_write_data(7 downto 0),
            o_sw_read_data    => bit_field_read_data(7 downto 0),
            o_sw_value        => bit_field_value(7 downto 0),
            o_write_trigger   => open,
            o_read_trigger    => open,
            i_hw_write_enable => "0",
            i_hw_write_data   => (others => '0'),
            i_hw_set          => (others => '0'),
            i_hw_clear        => (others => '0'),
            i_value           => i_SA_S(8*(i)+7 downto 8*(i)),
            i_mask            => (others => '1'),
            o_value           => open,
            o_value_unmasked  => open
          );
      end block;
    end generate;
  end block;
  g_Counter: block
    signal bit_field_valid: std_logic;
    signal bit_field_read_mask: std_logic_vector(63 downto 0);
    signal bit_field_write_mask: std_logic_vector(63 downto 0);
    signal bit_field_write_data: std_logic_vector(63 downto 0);
    signal bit_field_read_data: std_logic_vector(63 downto 0);
    signal bit_field_value: std_logic_vector(63 downto 0);
  begin
    \g_tie_off\: for \__i\ in 0 to 63 generate
      g: if (bit_slice(x"00000001ffffffff", \__i\) = '0') generate
        bit_field_read_data(\__i\) <= '0';
        bit_field_value(\__i\) <= '0';
      end generate;
    end generate;
    u_register: entity work.rggen_default_register
      generic map (
        READABLE        => true,
        WRITABLE        => false,
        ADDRESS_WIDTH   => 8,
        OFFSET_ADDRESS  => x"74",
        BUS_WIDTH       => 32,
        DATA_WIDTH      => 64
      )
      port map (
        i_clk                   => i_clk,
        i_rst_n                 => i_rst_n,
        i_register_valid        => register_valid,
        i_register_access       => register_access,
        i_register_address      => register_address,
        i_register_write_data   => register_write_data,
        i_register_strobe       => register_strobe,
        o_register_active       => register_active(28),
        o_register_ready        => register_ready(28),
        o_register_status       => register_status(57 downto 56),
        o_register_read_data    => register_read_data(927 downto 896),
        o_register_value        => register_value(1855 downto 1792),
        o_bit_field_valid       => bit_field_valid,
        o_bit_field_read_mask   => bit_field_read_mask,
        o_bit_field_write_mask  => bit_field_write_mask,
        o_bit_field_write_data  => bit_field_write_data,
        i_bit_field_read_data   => bit_field_read_data,
        i_bit_field_value       => bit_field_value
      );
    g_Value: block
    begin
      u_bit_field: entity work.rggen_bit_field
        generic map (
          WIDTH               => 33,
          STORAGE             => false,
          EXTERNAL_READ_DATA  => true,
          TRIGGER             => false
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_valid        => bit_field_valid,
          i_sw_read_mask    => bit_field_read_mask(32 downto 0),
          i_sw_write_enable => "0",
          i_sw_write_mask   => bit_field_write_mask(32 downto 0),
          i_sw_write_data   => bit_field_write_data(32 downto 0),
          o_sw_read_data    => bit_field_read_data(32 downto 0),
          o_sw_value        => bit_field_value(32 downto 0),
          o_write_trigger   => open,
          o_read_trigger    => open,
          i_hw_write_enable => "0",
          i_hw_write_data   => (others => '0'),
          i_hw_set          => (others => '0'),
          i_hw_clear        => (others => '0'),
          i_value           => i_Counter_Value,
          i_mask            => (others => '1'),
          o_value           => open,
          o_value_unmasked  => open
        );
    end block;
  end block;
  g_Mask: block
    signal bit_field_valid: std_logic;
    signal bit_field_read_mask: std_logic_vector(31 downto 0);
    signal bit_field_write_mask: std_logic_vector(31 downto 0);
    signal bit_field_write_data: std_logic_vector(31 downto 0);
    signal bit_field_read_data: std_logic_vector(31 downto 0);
    signal bit_field_value: std_logic_vector(31 downto 0);
  begin
    \g_tie_off\: for \__i\ in 0 to 31 generate
      g: if (bit_slice(x"0000ffff", \__i\) = '0') generate
        bit_field_read_data(\__i\) <= '0';
        bit_field_value(\__i\) <= '0';
      end generate;
    end generate;
    u_register: entity work.rggen_default_register
      generic map (
        READABLE        => true,
        WRITABLE        => true,
        ADDRESS_WIDTH   => 8,
        OFFSET_ADDRESS  => x"7c",
        BUS_WIDTH       => 32,
        DATA_WIDTH      => 32
      )
      port map (
        i_clk                   => i_clk,
        i_rst_n                 => i_rst_n,
        i_register_valid        => register_valid,
        i_register_access       => register_access,
        i_register_address      => register_address,
        i_register_write_data   => register_write_data,
        i_register_strobe       => register_strobe,
        o_register_active       => register_active(29),
        o_register_ready        => register_ready(29),
        o_register_status       => register_status(59 downto 58),
        o_register_read_data    => register_read_data(959 downto 928),
        o_register_value        => register_value(1887 downto 1856),
        o_bit_field_valid       => bit_field_valid,
        o_bit_field_read_mask   => bit_field_read_mask,
        o_bit_field_write_mask  => bit_field_write_mask,
        o_bit_field_write_data  => bit_field_write_data,
        i_bit_field_read_data   => bit_field_read_data,
        i_bit_field_value       => bit_field_value
      );
    g_Mask: block
    begin
      u_bit_field: entity work.rggen_bit_field
        generic map (
          WIDTH           => 16,
          INITIAL_VALUE   => slice(x"0000", 16, 0),
          SW_WRITE_ONCE   => false,
          TRIGGER         => false
        )
        port map (
          i_clk             => i_clk,
          i_rst_n           => i_rst_n,
          i_sw_valid        => bit_field_valid,
          i_sw_read_mask    => bit_field_read_mask(15 downto 0),
          i_sw_write_enable => "1",
          i_sw_write_mask   => bit_field_write_mask(15 downto 0),
          i_sw_write_data   => bit_field_write_data(15 downto 0),
          o_sw_read_data    => bit_field_read_data(15 downto 0),
          o_sw_value        => bit_field_value(15 downto 0),
          o_write_trigger   => open,
          o_read_trigger    => open,
          i_hw_write_enable => "0",
          i_hw_write_data   => (others => '0'),
          i_hw_set          => (others => '0'),
          i_hw_clear        => (others => '0'),
          i_value           => (others => '0'),
          i_mask            => (others => '1'),
          o_value           => o_Mask_Mask,
          o_value_unmasked  => open
        );
    end block;
  end block;
  g_Version: block
    signal bit_field_valid: std_logic;
    signal bit_field_read_mask: std_logic_vector(31 downto 0);
    signal bit_field_write_mask: std_logic_vector(31 downto 0);
    signal bit_field_write_data: std_logic_vector(31 downto 0);
    signal bit_field_read_data: std_logic_vector(31 downto 0);
    signal bit_field_value: std_logic_vector(31 downto 0);
  begin
    \g_tie_off\: for \__i\ in 0 to 31 generate
      g: if (bit_slice(x"00ffffff", \__i\) = '0') generate
        bit_field_read_data(\__i\) <= '0';
        bit_field_value(\__i\) <= '0';
      end generate;
    end generate;
    u_register: entity work.rggen_default_register
      generic map (
        READABLE        => true,
        WRITABLE        => false,
        ADDRESS_WIDTH   => 8,
        OFFSET_ADDRESS  => x"80",
        BUS_WIDTH       => 32,
        DATA_WIDTH      => 32
      )
      port map (
        i_clk                   => i_clk,
        i_rst_n                 => i_rst_n,
        i_register_valid        => register_valid,
        i_register_access       => register_access,
        i_register_address      => register_address,
        i_register_write_data   => register_write_data,
        i_register_strobe       => register_strobe,
        o_register_active       => register_active(30),
        o_register_ready        => register_ready(30),
        o_register_status       => register_status(61 downto 60),
        o_register_read_data    => register_read_data(991 downto 960),
        o_register_value        => register_value(1951 downto 1920),
        o_bit_field_valid       => bit_field_valid,
        o_bit_field_read_mask   => bit_field_read_mask,
        o_bit_field_write_mask  => bit_field_write_mask,
        o_bit_field_write_data  => bit_field_write_data,
        i_bit_field_read_data   => bit_field_read_data,
        i_bit_field_value       => bit_field_value
      );
    g_Version: block
    begin
      u_bit_field: entity work.rggen_bit_field
        generic map (
          WIDTH               => 24,
          STORAGE             => false,
          EXTERNAL_READ_DATA  => true
        )
        port map (
          i_clk             => '0',
          i_rst_n           => '0',
          i_sw_valid        => bit_field_valid,
          i_sw_read_mask    => bit_field_read_mask(23 downto 0),
          i_sw_write_enable => "0",
          i_sw_write_mask   => bit_field_write_mask(23 downto 0),
          i_sw_write_data   => bit_field_write_data(23 downto 0),
          o_sw_read_data    => bit_field_read_data(23 downto 0),
          o_sw_value        => bit_field_value(23 downto 0),
          o_write_trigger   => open,
          o_read_trigger    => open,
          i_hw_write_enable => "0",
          i_hw_write_data   => (others => '0'),
          i_hw_set          => (others => '0'),
          i_hw_clear        => (others => '0'),
          i_value           => slice(x"010102", 24, 0),
          i_mask            => (others => '1'),
          o_value           => open,
          o_value_unmasked  => open
        );
    end block;
  end block;
end rtl;
