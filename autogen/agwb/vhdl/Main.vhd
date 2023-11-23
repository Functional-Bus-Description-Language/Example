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
use work.Main_pkg.all;

entity Main is
  generic (
    g_C1_size : integer := c_C1_size;
    g_C2_size : integer := c_C2_size;
    g_C3_size : integer := c_C3_size;
    g_S1_size : integer := c_S1_size;
    g_S2_size : integer := c_S2_size;
    g_S3_size : integer := c_S3_size;
    g_CA4_size : integer := c_CA4_size;
    g_CA2_size : integer := c_CA2_size;
    g_SA4_size : integer := c_SA4_size;
    g_SA2_size : integer := c_SA2_size;
    g_Counter0_size : integer := c_Counter0_size;
    g_Counter1_size : integer := c_Counter1_size;
    g_Mask_size : integer := c_Mask_size;
    g_Version_size : integer := c_Version_size;
    g_Subblock_size : integer := c_Subblock_size;

    g_ver_id : std_logic_vector(31 downto 0) := c_Main_ver_id;
    g_registered : integer := 0
  );
  port (
    slave_i : in t_wishbone_slave_in;
    slave_o : out t_wishbone_slave_out;
    Subblock_wb_m_o : out t_wishbone_master_out;
    Subblock_wb_m_i : in t_wishbone_master_in := c_WB_SLAVE_OUT_ERR;

    C1_o : out  t_C1;
    C2_o : out  t_C2;
    C3_o : out  t_C3;
    S1_i : in  t_S1;
    S2_i : in  t_S2;
    S3_i : in  t_S3;
    CA4_o : out  ut_CA4_array(g_CA4_size - 1 downto 0);
    CA2_o : out  t_CA2;
    SA4_i : in  ut_SA4_array(g_SA4_size - 1 downto 0);
    SA2_i : in  t_SA2;
    Counter0_i : in  t_Counter0;
    Counter1_i : in  t_Counter1;
    Mask_o : out  t_Mask;
    Version_i : in  t_Version;

    rst_n_i : in std_logic;
    clk_sys_i : in std_logic
    );

end Main;

architecture gener of Main is
  signal int_C1_o : t_C1;
  signal int_C2_o : t_C2;
  signal int_C3_o : t_C3;
  signal int_CA4_o : ut_CA4_array(g_CA4_size - 1 downto 0);
  signal int_CA2_o : t_CA2;
  signal int_Mask_o : t_Mask;


  -- Internal WB declaration
  signal int_regs_wb_m_o : t_wishbone_master_out;
  signal int_regs_wb_m_i : t_wishbone_master_in;
  signal int_addr : std_logic_vector(5-1 downto 0);
  signal wb_up_o : t_wishbone_slave_out_array(1-1 downto 0);
  signal wb_up_i : t_wishbone_slave_in_array(1-1 downto 0);
  signal wb_up_r_o : t_wishbone_slave_out_array(1-1 downto 0);
  signal wb_up_r_i : t_wishbone_slave_in_array(1-1 downto 0);
  signal wb_m_o : t_wishbone_master_out_array(2-1 downto 0);
  signal wb_m_i : t_wishbone_master_in_array(2-1 downto 0) := (others => c_WB_SLAVE_OUT_ERR);

  -- Constants
  constant c_address : t_wishbone_address_array(2-1  downto 0) := (0=>"00000000000000000000000000000000",1=>"00000000000000000000000000111000");
  constant c_mask : t_wishbone_address_array(2-1 downto 0) := (0=>"00000000000000000000000000100000",1=>"00000000000000000000000000111000");
begin
  
  assert g_C1_size <= c_C1_size report "g_C1_size must be not greater than c_C1_size=1" severity failure;
  assert g_C2_size <= c_C2_size report "g_C2_size must be not greater than c_C2_size=1" severity failure;
  assert g_C3_size <= c_C3_size report "g_C3_size must be not greater than c_C3_size=1" severity failure;
  assert g_S1_size <= c_S1_size report "g_S1_size must be not greater than c_S1_size=1" severity failure;
  assert g_S2_size <= c_S2_size report "g_S2_size must be not greater than c_S2_size=1" severity failure;
  assert g_S3_size <= c_S3_size report "g_S3_size must be not greater than c_S3_size=1" severity failure;
  assert g_CA4_size <= c_CA4_size report "g_CA4_size must be not greater than c_CA4_size=2" severity failure;
  assert g_CA2_size <= c_CA2_size report "g_CA2_size must be not greater than c_CA2_size=1" severity failure;
  assert g_SA4_size <= c_SA4_size report "g_SA4_size must be not greater than c_SA4_size=2" severity failure;
  assert g_SA2_size <= c_SA2_size report "g_SA2_size must be not greater than c_SA2_size=1" severity failure;
  assert g_Counter0_size <= c_Counter0_size report "g_Counter0_size must be not greater than c_Counter0_size=1" severity failure;
  assert g_Counter1_size <= c_Counter1_size report "g_Counter1_size must be not greater than c_Counter1_size=1" severity failure;
  assert g_Mask_size <= c_Mask_size report "g_Mask_size must be not greater than c_Mask_size=1" severity failure;
  assert g_Version_size <= c_Version_size report "g_Version_size must be not greater than c_Version_size=1" severity failure;
  assert g_Subblock_size <= c_Subblock_size report "g_Subblock_size must be not greater than c_Subblock_size=1" severity failure;

  wb_up_i(0) <= slave_i;
  slave_o <= wb_up_o(0);
  int_addr <= int_regs_wb_m_o.adr(5-1 downto 0);

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
     g_num_slaves  => 2,
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
          for i in 0 to g_C1_size - 1 loop
            if int_addr = std_logic_vector(to_unsigned(2 + i, 5)) then
              int_regs_wb_m_i.dat <= (others => '0');
              int_regs_wb_m_i.dat(6 downto 0) <= std_logic_vector(int_C1_o);
              if int_regs_wb_m_o.we = '1' then
                int_C1_o <= std_logic_vector(int_regs_wb_m_o.dat(6 downto 0));
              end if;
              int_regs_wb_m_i.ack <= '1';
              int_regs_wb_m_i.err <= '0';
            end if;
          end loop; -- g_C1_size
          
          -- That's a single register that may be present (size=1) or not (size=0).
          -- The "for" loop works like "if".
          -- That's why we do not index the register inside the loop.
          for i in 0 to g_C2_size - 1 loop
            if int_addr = std_logic_vector(to_unsigned(3 + i, 5)) then
              int_regs_wb_m_i.dat <= (others => '0');
              int_regs_wb_m_i.dat(8 downto 0) <= std_logic_vector(int_C2_o);
              if int_regs_wb_m_o.we = '1' then
                int_C2_o <= std_logic_vector(int_regs_wb_m_o.dat(8 downto 0));
              end if;
              int_regs_wb_m_i.ack <= '1';
              int_regs_wb_m_i.err <= '0';
            end if;
          end loop; -- g_C2_size
          
          -- That's a single register that may be present (size=1) or not (size=0).
          -- The "for" loop works like "if".
          -- That's why we do not index the register inside the loop.
          for i in 0 to g_C3_size - 1 loop
            if int_addr = std_logic_vector(to_unsigned(4 + i, 5)) then
              int_regs_wb_m_i.dat <= (others => '0');
              int_regs_wb_m_i.dat(11 downto 0) <= std_logic_vector(int_C3_o);
              if int_regs_wb_m_o.we = '1' then
                int_C3_o <= std_logic_vector(int_regs_wb_m_o.dat(11 downto 0));
              end if;
              int_regs_wb_m_i.ack <= '1';
              int_regs_wb_m_i.err <= '0';
            end if;
          end loop; -- g_C3_size
          
          -- That's a single register that may be present (size=1) or not (size=0).
          -- The "for" loop works like "if".
          -- That's why we do not index the register inside the loop.
          for i in 0 to g_S1_size - 1 loop
            if int_addr = std_logic_vector(to_unsigned(5 + i, 5)) then
              int_regs_wb_m_i.dat <= (others => '0');
              int_regs_wb_m_i.dat(6 downto 0) <= std_logic_vector(S1_i);
              int_regs_wb_m_i.ack <= '1';
              int_regs_wb_m_i.err <= '0';
            end if;
          end loop; -- g_S1_size
          
          -- That's a single register that may be present (size=1) or not (size=0).
          -- The "for" loop works like "if".
          -- That's why we do not index the register inside the loop.
          for i in 0 to g_S2_size - 1 loop
            if int_addr = std_logic_vector(to_unsigned(6 + i, 5)) then
              int_regs_wb_m_i.dat <= (others => '0');
              int_regs_wb_m_i.dat(8 downto 0) <= std_logic_vector(S2_i);
              int_regs_wb_m_i.ack <= '1';
              int_regs_wb_m_i.err <= '0';
            end if;
          end loop; -- g_S2_size
          
          -- That's a single register that may be present (size=1) or not (size=0).
          -- The "for" loop works like "if".
          -- That's why we do not index the register inside the loop.
          for i in 0 to g_S3_size - 1 loop
            if int_addr = std_logic_vector(to_unsigned(7 + i, 5)) then
              int_regs_wb_m_i.dat <= (others => '0');
              int_regs_wb_m_i.dat(11 downto 0) <= std_logic_vector(S3_i);
              int_regs_wb_m_i.ack <= '1';
              int_regs_wb_m_i.err <= '0';
            end if;
          end loop; -- g_S3_size
          for i in 0 to g_CA4_size - 1 loop
            if int_addr = std_logic_vector(to_unsigned(8 + i, 5)) then
              int_regs_wb_m_i.dat <= (others => '0');
              int_regs_wb_m_i.dat(31 downto 0) <= to_slv(int_CA4_o( i ));
              if int_regs_wb_m_o.we = '1' then
                int_CA4_o( i ) <= to_CA4(int_regs_wb_m_o.dat(31 downto 0));
              end if;
              int_regs_wb_m_i.ack <= '1';
              int_regs_wb_m_i.err <= '0';
            end if;
          end loop; -- g_CA4_size
          
          -- That's a single register that may be present (size=1) or not (size=0).
          -- The "for" loop works like "if".
          -- That's why we do not index the register inside the loop.
          for i in 0 to g_CA2_size - 1 loop
            if int_addr = std_logic_vector(to_unsigned(10 + i, 5)) then
              int_regs_wb_m_i.dat <= (others => '0');
              int_regs_wb_m_i.dat(15 downto 0) <= to_slv(int_CA2_o);
              if int_regs_wb_m_o.we = '1' then
                int_CA2_o <= to_CA2(int_regs_wb_m_o.dat(15 downto 0));
              end if;
              int_regs_wb_m_i.ack <= '1';
              int_regs_wb_m_i.err <= '0';
            end if;
          end loop; -- g_CA2_size
          for i in 0 to g_SA4_size - 1 loop
            if int_addr = std_logic_vector(to_unsigned(11 + i, 5)) then
              int_regs_wb_m_i.dat <= (others => '0');
              int_regs_wb_m_i.dat(31 downto 0) <= to_slv(SA4_i( i ));
              int_regs_wb_m_i.ack <= '1';
              int_regs_wb_m_i.err <= '0';
            end if;
          end loop; -- g_SA4_size
          
          -- That's a single register that may be present (size=1) or not (size=0).
          -- The "for" loop works like "if".
          -- That's why we do not index the register inside the loop.
          for i in 0 to g_SA2_size - 1 loop
            if int_addr = std_logic_vector(to_unsigned(13 + i, 5)) then
              int_regs_wb_m_i.dat <= (others => '0');
              int_regs_wb_m_i.dat(15 downto 0) <= to_slv(SA2_i);
              int_regs_wb_m_i.ack <= '1';
              int_regs_wb_m_i.err <= '0';
            end if;
          end loop; -- g_SA2_size
          
          -- That's a single register that may be present (size=1) or not (size=0).
          -- The "for" loop works like "if".
          -- That's why we do not index the register inside the loop.
          for i in 0 to g_Counter0_size - 1 loop
            if int_addr = std_logic_vector(to_unsigned(14 + i, 5)) then
              int_regs_wb_m_i.dat <= (others => '0');
              int_regs_wb_m_i.dat(31 downto 0) <= std_logic_vector(Counter0_i);
              int_regs_wb_m_i.ack <= '1';
              int_regs_wb_m_i.err <= '0';
            end if;
          end loop; -- g_Counter0_size
          
          -- That's a single register that may be present (size=1) or not (size=0).
          -- The "for" loop works like "if".
          -- That's why we do not index the register inside the loop.
          for i in 0 to g_Counter1_size - 1 loop
            if int_addr = std_logic_vector(to_unsigned(15 + i, 5)) then
              int_regs_wb_m_i.dat <= (others => '0');
              int_regs_wb_m_i.dat(0 downto 0) <= std_logic_vector(Counter1_i);
              int_regs_wb_m_i.ack <= '1';
              int_regs_wb_m_i.err <= '0';
            end if;
          end loop; -- g_Counter1_size
          
          -- That's a single register that may be present (size=1) or not (size=0).
          -- The "for" loop works like "if".
          -- That's why we do not index the register inside the loop.
          for i in 0 to g_Mask_size - 1 loop
            if int_addr = std_logic_vector(to_unsigned(16 + i, 5)) then
              int_regs_wb_m_i.dat <= (others => '0');
              int_regs_wb_m_i.dat(15 downto 0) <= std_logic_vector(int_Mask_o);
              if int_regs_wb_m_o.we = '1' then
                int_Mask_o <= std_logic_vector(int_regs_wb_m_o.dat(15 downto 0));
              end if;
              int_regs_wb_m_i.ack <= '1';
              int_regs_wb_m_i.err <= '0';
            end if;
          end loop; -- g_Mask_size
          
          -- That's a single register that may be present (size=1) or not (size=0).
          -- The "for" loop works like "if".
          -- That's why we do not index the register inside the loop.
          for i in 0 to g_Version_size - 1 loop
            if int_addr = std_logic_vector(to_unsigned(17 + i, 5)) then
              int_regs_wb_m_i.dat <= (others => '0');
              int_regs_wb_m_i.dat(23 downto 0) <= std_logic_vector(Version_i);
              int_regs_wb_m_i.ack <= '1';
              int_regs_wb_m_i.err <= '0';
            end if;
          end loop; -- g_Version_size


          if int_addr = "00000" then
             int_regs_wb_m_i.dat <= x"1f1a625a";
             if int_regs_wb_m_o.we = '1' then
                int_regs_wb_m_i.err <= '1';
                int_regs_wb_m_i.ack <= '0';
             else
                int_regs_wb_m_i.ack <= '1';
                int_regs_wb_m_i.err <= '0';
             end if;
          end if;
          if int_addr = "00001" then
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
  C1_o <= int_C1_o;
  C2_o <= int_C2_o;
  C3_o <= int_C3_o;
  CA4_o <= int_CA4_o;
  CA2_o <= int_CA2_o;
  Mask_o <= int_Mask_o;
  wb_m_i(0) <= int_regs_wb_m_i;
  int_regs_wb_m_o  <= wb_m_o(0);
  bg1: if g_Subblock_size > 0 generate
    wb_m_i(1) <= Subblock_wb_m_i;
    Subblock_wb_m_o  <= wb_m_o(1);
  end generate; -- g_Subblock_size

end architecture;
