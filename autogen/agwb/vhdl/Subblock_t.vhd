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
use work.Subblock_t_pkg.all;

entity Subblock_t is
  generic (
    g_Add0_size : integer := c_Add0_size;
    g_Add1_size : integer := c_Add1_size;
    g_Sum_size : integer := c_Sum_size;

    g_ver_id : std_logic_vector(31 downto 0) := c_Subblock_t_ver_id;
    g_registered : integer := 0
  );
  port (
    slave_i : in t_wishbone_slave_in;
    slave_o : out t_wishbone_slave_out;

    Add0_o : out  t_Add0;
    Add1_o : out  t_Add1;
    Add1_o_stb : out std_logic;
    Sum_i : in  t_Sum;

    rst_n_i : in std_logic;
    clk_sys_i : in std_logic
    );

end Subblock_t;

architecture gener of Subblock_t is
  signal int_Add0_o : t_Add0;
  signal int_Add1_o : t_Add1;
  signal int_Add1_o_stb : std_logic;


  -- Internal WB declaration
  signal int_regs_wb_m_o : t_wishbone_master_out;
  signal int_regs_wb_m_i : t_wishbone_master_in;
  signal int_addr : std_logic_vector(3-1 downto 0);
  signal wb_up_o : t_wishbone_slave_out_array(1-1 downto 0);
  signal wb_up_i : t_wishbone_slave_in_array(1-1 downto 0);
  signal wb_up_r_o : t_wishbone_slave_out_array(1-1 downto 0);
  signal wb_up_r_i : t_wishbone_slave_in_array(1-1 downto 0);
  signal wb_m_o : t_wishbone_master_out_array(1-1 downto 0);
  signal wb_m_i : t_wishbone_master_in_array(1-1 downto 0) := (others => c_WB_SLAVE_OUT_ERR);

  -- Constants
  constant c_address : t_wishbone_address_array(1-1  downto 0) := (0=>"00000000000000000000000000000000");
  constant c_mask : t_wishbone_address_array(1-1 downto 0) := (0=>"00000000000000000000000000000000");
begin
  
  assert g_Add0_size <= c_Add0_size report "g_Add0_size must be not greater than c_Add0_size=1" severity failure;
  assert g_Add1_size <= c_Add1_size report "g_Add1_size must be not greater than c_Add1_size=1" severity failure;
  assert g_Sum_size <= c_Sum_size report "g_Sum_size must be not greater than c_Sum_size=1" severity failure;

  wb_up_i(0) <= slave_i;
  slave_o <= wb_up_o(0);
  int_addr <= int_regs_wb_m_o.adr(3-1 downto 0);

-- Conditional adding of xwb_register   
  gr1: if g_registered = 2 generate
    grl1: for i in 0 to 1-1 generate
      xwb_register_1: entity general_cores.xwb_register
      generic map (
        g_WB_MODE => CLASSIC)
      port map (
        rst_n_i  => rst_n_i,
        clk_i    => clk_sys_i,
        slave_i  => wb_up_i(i),
        slave_o  => wb_up_o(i),
        master_i => wb_up_r_o(i),
        master_o => wb_up_r_i(i));
    end generate grl1;
  end generate gr1;

  gr2: if g_registered /= 2 generate
      wb_up_r_i <= wb_up_i;
      wb_up_o <= wb_up_r_o;
  end generate gr2;

-- Main crossbar
  xwb_crossbar_1: entity general_cores.xwb_crossbar
  generic map (
     g_num_masters => 1,
     g_num_slaves  => 1,
     g_registered  => (g_registered = 1),
     g_address     => c_address,
     g_mask        => c_mask
  )
  port map (
     clk_sys_i => clk_sys_i,
     rst_n_i   => rst_n_i,
     slave_i   => wb_up_r_i,
     slave_o   => wb_up_r_o,
     master_i  => wb_m_i,
     master_o  => wb_m_o,
     sdb_sel_o => open
  );

-- Process for register access
  process(clk_sys_i)
  begin
    if rising_edge(clk_sys_i) then
      if rst_n_i = '0' then
        -- Reset of the core
        int_regs_wb_m_i <= c_DUMMY_WB_MASTER_IN;

      else
        -- Clearing of trigger bits (if there are any)

        -- Normal operation
        int_regs_wb_m_i.rty <= '0';
        int_regs_wb_m_i.ack <= '0';
        int_regs_wb_m_i.err <= '0';
        int_Add1_o_stb <= '0';

        if (int_regs_wb_m_o.cyc = '1') and (int_regs_wb_m_o.stb = '1')
            and (int_regs_wb_m_i.err = '0') and (int_regs_wb_m_i.rty = '0')
            and (int_regs_wb_m_i.ack = '0') then
          int_regs_wb_m_i.err <= '1'; -- in case of missed address
          -- Access, now we handle consecutive registers
          -- Set the error state so it is output when none register is accessed
          int_regs_wb_m_i.dat <= x"A5A5A5A5";
          int_regs_wb_m_i.ack <= '0';
          int_regs_wb_m_i.err <= '1';
          
          -- That's a single register that may be present (size=1) or not (size=0).
          -- The "for" loop works like "if".
          -- That's why we do not index the register inside the loop.
          for i in 0 to g_Add0_size - 1 loop
            if int_addr = std_logic_vector(to_unsigned(2 + i, 3)) then
              int_regs_wb_m_i.dat <= (others => '0');
              int_regs_wb_m_i.dat(29 downto 0) <= to_slv(int_Add0_o);
              if int_regs_wb_m_o.we = '1' then
                int_Add0_o <= to_Add0(int_regs_wb_m_o.dat(29 downto 0));
              end if;
              int_regs_wb_m_i.ack <= '1';
              int_regs_wb_m_i.err <= '0';
            end if;
          end loop; -- g_Add0_size
          
          -- That's a single register that may be present (size=1) or not (size=0).
          -- The "for" loop works like "if".
          -- That's why we do not index the register inside the loop.
          for i in 0 to g_Add1_size - 1 loop
            if int_addr = std_logic_vector(to_unsigned(3 + i, 3)) then
              int_regs_wb_m_i.dat <= (others => '0');
              int_regs_wb_m_i.dat(7 downto 0) <= to_slv(int_Add1_o);
              if int_regs_wb_m_o.we = '1' then
                int_Add1_o <= to_Add1(int_regs_wb_m_o.dat(7 downto 0));
                if int_regs_wb_m_i.ack = '0' then
                  int_Add1_o_stb <= '1';
                end if;
              end if;
              int_regs_wb_m_i.ack <= '1';
              int_regs_wb_m_i.err <= '0';
            end if;
          end loop; -- g_Add1_size
          
          -- That's a single register that may be present (size=1) or not (size=0).
          -- The "for" loop works like "if".
          -- That's why we do not index the register inside the loop.
          for i in 0 to g_Sum_size - 1 loop
            if int_addr = std_logic_vector(to_unsigned(4 + i, 3)) then
              int_regs_wb_m_i.dat <= (others => '0');
              int_regs_wb_m_i.dat(20 downto 0) <= std_logic_vector(Sum_i);
              int_regs_wb_m_i.ack <= '1';
              int_regs_wb_m_i.err <= '0';
            end if;
          end loop; -- g_Sum_size


          if int_addr = "000" then
             int_regs_wb_m_i.dat <= x"e6748e82";
             if int_regs_wb_m_o.we = '1' then
                int_regs_wb_m_i.err <= '1';
                int_regs_wb_m_i.ack <= '0';
             else
                int_regs_wb_m_i.ack <= '1';
                int_regs_wb_m_i.err <= '0';
             end if;
          end if;
          if int_addr = "001" then
             int_regs_wb_m_i.dat <= g_ver_id;
             if int_regs_wb_m_o.we = '1' then
                int_regs_wb_m_i.err <= '1';
                int_regs_wb_m_i.ack <= '0';
             else
                int_regs_wb_m_i.ack <= '1';
                int_regs_wb_m_i.err <= '0';
             end if;
          end if;
        end if;
      end if;
    end if;
  end process;
  Add0_o <= int_Add0_o;
  Add1_o <= int_Add1_o;
  Add1_o_stb <= int_Add1_o_stb;
  wb_m_i(0) <= int_regs_wb_m_i;
  int_regs_wb_m_o  <= wb_m_o(0);

end architecture;
