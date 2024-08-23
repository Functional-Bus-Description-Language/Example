-- Generated using vhdMMIO 0.0.3 (https://github.com/abs-tudelft/vhdmmio)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library work;
use work.vhdmmio_pkg.all;
use work.Subblock_pkg.all;

entity Subblock is
  port (

    -- Clock sensitive to the rising edge and synchronous, active-high reset.
    clk : in std_logic;
    reset : in std_logic := '0';

    -- Interface group for:
    --  - field A: A.
    --  - field AddStb: AddStb.
    --  - field B: B.
    --  - field C: C.
    g_Add_o : out subblock_g_add_o_type := SUBBLOCK_G_ADD_O_RESET;

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
end Subblock;

architecture behavioral of Subblock is
begin
  reg_proc: process (clk) is

    -- Convenience function for unsigned accumulation with differing vector
    -- widths.
    procedure accum_add(
      accum: inout std_logic_vector;
      addend: std_logic_vector) is
    begin
      accum := std_logic_vector(
        unsigned(accum) + resize(unsigned(addend), accum'length));
    end procedure accum_add;

    -- Convenience function for unsigned subtraction with differing vector
    -- widths.
    procedure accum_sub(
      accum: inout std_logic_vector;
      addend: std_logic_vector) is
    begin
      accum := std_logic_vector(
        unsigned(accum) - resize(unsigned(addend), accum'length));
    end procedure accum_sub;

    -- Bus response output register.
    variable bus_v : axi4l32_s2m_type := AXI4L32_S2M_RESET; -- reg

    -- Holding registers for the AXI4-lite request channels. Having these
    -- allows us to make the accompanying ready signals register outputs
    -- without sacrificing a cycle's worth of delay for every transaction.
    variable awl : axi4la_type := AXI4LA_RESET; -- reg
    variable wl  : axi4lw32_type := AXI4LW32_RESET; -- reg
    variable arl : axi4la_type := AXI4LA_RESET; -- reg

    -- Request flags for the register logic. When asserted, a request is
    -- present in awl/wl/arl, and the response can be returned immediately.
    -- This is used by simple registers.
    variable w_req : boolean := false;
    variable r_req : boolean := false;

    -- As above, but asserted when there is a request that can NOT be returned
    -- immediately for whatever reason, but CAN be started already if deferral
    -- is supported by the targeted block. Abbreviation for lookahead request.
    -- Note that *_lreq implies *_req.
    variable w_lreq : boolean := false;
    variable r_lreq : boolean := false;

    -- Request signals. w_strb is a validity bit for each data bit; it actually
    -- always has byte granularity but encoding it this way makes the code a
    -- lot nicer (and it should be optimized to the same thing by any sane
    -- synthesizer).
    variable w_addr : std_logic_vector(31 downto 0);
    variable w_data : std_logic_vector(31 downto 0) := (others => '0');
    variable w_strb : std_logic_vector(31 downto 0) := (others => '0');
    constant w_prot : std_logic_vector(2 downto 0) := (others => '0');
    variable r_addr : std_logic_vector(31 downto 0);
    constant r_prot : std_logic_vector(2 downto 0) := (others => '0');

    -- Logical write data holding registers. For multi-word registers, write
    -- data is held in w_hold and w_hstb until the last subregister is written,
    -- at which point their entire contents are written at once.
    variable w_hold : std_logic_vector(63 downto 0) := (others => '0'); -- reg
    variable w_hstb : std_logic_vector(63 downto 0) := (others => '0'); -- reg

    -- Between the first and last access to a multiword register, the multi
    -- bit will be set. If it is set while a request with a different *_prot is
    -- received, the interrupting request is rejected if it is A) non-secure
    -- while the interrupted request is secure or B) unprivileged while the
    -- interrupted request is privileged. If it is not rejected, previously
    -- buffered data is cleared and masked. Within the same security level, it
    -- is up to the bus master to not mess up its own access pattern. The last
    -- access to a multiword register clears the bit; for the read end r_hold
    -- is also cleared in this case to prevent data leaks.
    variable w_multi : std_logic := '0'; -- reg
    variable r_multi : std_logic := '0'; -- reg

    -- Response flags. When *_req is set and *_addr matches a register, it must
    -- set at least one of these flags; when *_rreq is set and *_rtag matches a
    -- register, it must also set at least one of these, except it cannot set
    -- *_defer. A decode error can be generated by intentionally NOT setting
    -- any of these flags, but this should only be done by registers that
    -- contain only one field (usually, these would be AXI-lite passthrough
    -- "registers"). The action taken by the non-register-specific logic is as
    -- follows (priority decoder):
    --
    --  - if *_defer is set, push *_dtag into the deferal FIFO;
    --  - if *_block is set, do nothing;
    --  - otherwise, if *_nack is set, send a slave error response;
    --  - otherwise, if *_ack is set, send a positive response;
    --  - otherwise, send a decode error response.
    --
    -- In addition to the above, the request stream(s) will be handshaked if
    -- *_req was set and a response is sent or the response is deferred.
    -- Likewise, the deferal FIFO will be popped if *_rreq was set and a
    -- response is sent.
    --
    -- The valid states can be summarized as follows:
    --
    -- .----------------------------------------------------------------------------------.
    -- | req | lreq | rreq || ack | nack | block | defer || request | response | defer    |
    -- |-----+------+------||-----+------+-------+-------||---------+----------+----------|
    -- |  0  |  0   |  0   ||  0  |  0   |   0   |   0   ||         |          |          | Idle.
    -- |-----+------+------||-----+------+-------+-------||---------+----------+----------|
    -- |  0  |  0   |  1   ||  0  |  0   |   0   |   0   ||         | dec_err  | pop      | Completing
    -- |  0  |  0   |  1   ||  1  |  0   |   0   |   0   ||         | ack      | pop      | previous,
    -- |  0  |  0   |  1   ||  -  |  1   |   0   |   0   ||         | slv_err  | pop      | no
    -- |  0  |  0   |  1   ||  -  |  -   |   1   |   0   ||         |          |          | lookahead.
    -- |-----+------+------||-----+------+-------+-------||---------+----------+----------|
    -- |  1  |  0   |  0   ||  0  |  0   |   0   |   0   || accept  | dec_err  |          | Responding
    -- |  1  |  0   |  0   ||  1  |  0   |   0   |   0   || accept  | ack      |          | immediately
    -- |  1  |  0   |  0   ||  -  |  1   |   0   |   0   || accept  | slv_err  |          | to incoming
    -- |  1  |  0   |  0   ||  -  |  -   |   1   |   0   ||         |          |          | request.
    -- |-----+------+------||-----+------+-------+-------||---------+----------+----------|
    -- |  1  |  0   |  0   ||  0  |  0   |   0   |   1   || accept  |          | push     | Deferring.
    -- |  0  |  1   |  0   ||  0  |  0   |   0   |   1   || accept  |          | push     | Deferring.
    -- |-----+------+------||-----+------+-------+-------||---------+----------+----------|
    -- |  0  |  1   |  1   ||  0  |  0   |   0   |   0   ||         | dec_err  | pop      | Completing
    -- |  0  |  1   |  1   ||  1  |  0   |   0   |   0   ||         | ack      | pop      | previous,
    -- |  0  |  1   |  1   ||  -  |  1   |   0   |   0   ||         | slv_err  | pop      | ignoring
    -- |  0  |  1   |  1   ||  -  |  -   |   1   |   0   ||         |          |          | lookahead.
    -- |-----+------+------||-----+------+-------+-------||---------+----------+----------|
    -- |  0  |  1   |  1   ||  0  |  0   |   0   |   1   || accept  | dec_err  | pop+push | Completing
    -- |  0  |  1   |  1   ||  1  |  0   |   0   |   1   || accept  | ack      | pop+push | previous,
    -- |  0  |  1   |  1   ||  -  |  1   |   0   |   1   || accept  | slv_err  | pop+push | deferring
    -- |  0  |  1   |  1   ||  -  |  -   |   1   |   1   || accept  |          | push     | lookahead.
    -- '----------------------------------------------------------------------------------'
    --
    -- This can be simplified to the following:
    --
    -- .----------------------------------------------------------------------------------.
    -- | req | lreq | rreq || ack | nack | block | defer || request | response | defer    |
    -- |-----+------+------||-----+------+-------+-------||---------+----------+----------|
    -- |  -  |  -   |  -   ||  -  |  -   |   1   |   -   ||         |          |          |
    -- |-----+------+------||-----+------+-------+-------||---------+----------+----------|
    -- |  -  |  -   |  1   ||  -  |  1   |   0   |   -   ||         | slv_err  | pop      |
    -- |  1  |  -   |  0   ||  -  |  1   |   0   |   -   || accept  | slv_err  |          |
    -- |-----+------+------||-----+------+-------+-------||---------+----------+----------|
    -- |  -  |  -   |  1   ||  1  |  0   |   0   |   -   ||         | ack      | pop      |
    -- |  1  |  -   |  0   ||  1  |  0   |   0   |   -   || accept  | ack      |          |
    -- |-----+------+------||-----+------+-------+-------||---------+----------+----------|
    -- |  -  |  -   |  1   ||  0  |  0   |   0   |   -   ||         | dec_err  | pop      |
    -- |  1  |  -   |  0   ||  0  |  0   |   0   |   -   || accept  | dec_err  |          |
    -- |-----+------+------||-----+------+-------+-------||---------+----------+----------|
    -- |  -  |  -   |  -   ||  -  |  -   |   -   |   1   || accept  |          | push     |
    -- '----------------------------------------------------------------------------------'
    --
    variable w_block : boolean := false;
    variable r_block : boolean := false;
    variable w_nack  : boolean := false;
    variable r_nack  : boolean := false;
    variable w_ack   : boolean := false;
    variable r_ack   : boolean := false;

    -- Logical read data holding register. This is set when r_ack is set during
    -- an access to the first physical register of a logical register for all
    -- fields in the logical register.
    variable r_hold  : std_logic_vector(63 downto 0) := (others => '0'); -- reg

    -- Physical read data. This is taken from r_hold based on which physical
    -- subregister is being read.
    variable r_data  : std_logic_vector(31 downto 0);

    -- Subaddress variables, used to index within large fields like memories and
    -- AXI passthroughs.
    variable subaddr_none         : std_logic_vector(0 downto 0);

    -- Private declarations for field A: A.
    type f_A_r_type is record
      d : std_logic_vector(19 downto 0);
      v : std_logic;
    end record;
    constant F_A_R_RESET : f_A_r_type := (
      d => (others => '0'),
      v => '0'
    );
    type f_A_r_array is array (natural range <>) of f_A_r_type;
    variable f_A_r : f_A_r_array(0 to 0) := (others => F_A_R_RESET);

    -- Private declarations for field B: B.
    type f_B_r_type is record
      d : std_logic_vector(9 downto 0);
      v : std_logic;
    end record;
    constant F_B_R_RESET : f_B_r_type := (
      d => (others => '0'),
      v => '0'
    );
    type f_B_r_array is array (natural range <>) of f_B_r_type;
    variable f_B_r : f_B_r_array(0 to 0) := (others => F_B_R_RESET);

    -- Private declarations for field C: C.
    type f_C_r_type is record
      d : std_logic_vector(7 downto 0);
      v : std_logic;
    end record;
    constant F_C_R_RESET : f_C_r_type := (
      d => (others => '0'),
      v => '0'
    );
    type f_C_r_array is array (natural range <>) of f_C_r_type;
    variable f_C_r : f_C_r_array(0 to 0) := (others => F_C_R_RESET);

    -- Private declarations for field AddStb: AddStb.
    type f_AddStb_r_type is record
      d : std_logic_vector(31 downto 0);
      v : std_logic;
      inval : std_logic;
    end record;
    constant F_ADDSTB_R_RESET : f_AddStb_r_type := (
      d => (others => '0'),
      v => '0',
      inval => '0'
    );
    type f_AddStb_r_array is array (natural range <>) of f_AddStb_r_type;
    variable f_AddStb_r : f_AddStb_r_array(0 to 0)
        := (others => F_ADDSTB_R_RESET);

    -- Private declarations for field Sum: Sum.
    type f_Sum_r_type is record
      d : std_logic_vector(20 downto 0);
      v : std_logic;
    end record;
    constant F_SUM_R_RESET : f_Sum_r_type := (
      d => (others => '0'),
      v => '0'
    );
    type f_Sum_r_array is array (natural range <>) of f_Sum_r_type;
    variable f_Sum_r : f_Sum_r_array(0 to 0) := (others => F_SUM_R_RESET);

    -- Private declarations for field AS: AS.
    type f_AS_r_type is record
      d : std_logic_vector(19 downto 0);
      v : std_logic;
    end record;
    constant F_AS_R_RESET : f_AS_r_type := (
      d => (others => '0'),
      v => '0'
    );
    type f_AS_r_array is array (natural range <>) of f_AS_r_type;
    variable f_AS_r : f_AS_r_array(0 to 0) := (others => F_AS_R_RESET);

    -- Private declarations for field BS: BS.
    type f_BS_r_type is record
      d : std_logic_vector(9 downto 0);
      v : std_logic;
    end record;
    constant F_BS_R_RESET : f_BS_r_type := (
      d => (others => '0'),
      v => '0'
    );
    type f_BS_r_array is array (natural range <>) of f_BS_r_type;
    variable f_BS_r : f_BS_r_array(0 to 0) := (others => F_BS_R_RESET);

    -- Private declarations for field CS: CS.
    type f_CS_r_type is record
      d : std_logic_vector(7 downto 0);
      v : std_logic;
    end record;
    constant F_CS_R_RESET : f_CS_r_type := (
      d => (others => '0'),
      v => '0'
    );
    type f_CS_r_array is array (natural range <>) of f_CS_r_type;
    variable f_CS_r : f_CS_r_array(0 to 0) := (others => F_CS_R_RESET);

    -- Private declarations for field Sum_Stream: Sum_Stream.
    type f_Sum_Stream_r_type is record
      d : std_logic_vector(20 downto 0);
      v : std_logic;
    end record;
    constant F_SUM_STREAM_R_RESET : f_Sum_Stream_r_type := (
      d => (others => '0'),
      v => '0'
    );
    type f_Sum_Stream_r_array is array (natural range <>) of f_Sum_Stream_r_type;
    variable f_Sum_Stream_r : f_Sum_Stream_r_array(0 to 0)
        := (others => F_SUM_STREAM_R_RESET);

    -- Temporary variables for the field templates.
    variable tmp_data8   : std_logic_vector(7 downto 0);
    variable tmp_strb8   : std_logic_vector(7 downto 0);
    variable tmp_data10  : std_logic_vector(9 downto 0);
    variable tmp_strb10  : std_logic_vector(9 downto 0);
    variable tmp_data20  : std_logic_vector(19 downto 0);
    variable tmp_strb20  : std_logic_vector(19 downto 0);
    variable tmp_data21  : std_logic_vector(20 downto 0);
    variable tmp_data32  : std_logic_vector(31 downto 0);
    variable tmp_strb32  : std_logic_vector(31 downto 0);

  begin
    if rising_edge(clk) then

      -- Reset variables that shouldn't become registers to default values.
      w_req   := false;
      r_req   := false;
      w_lreq  := false;
      r_lreq  := false;
      w_addr  := (others => '0');
      w_data  := (others => '0');
      w_strb  := (others => '0');
      r_addr  := (others => '0');
      w_block := false;
      r_block := false;
      w_nack  := false;
      r_nack  := false;
      w_ack   := false;
      r_ack   := false;
      r_data  := (others => '0');

      -------------------------------------------------------------------------
      -- Finish up the previous cycle
      -------------------------------------------------------------------------
      -- Invalidate responses that were acknowledged by the master in the
      -- previous cycle.
      if bus_i.b.ready = '1' then
        bus_v.b.valid := '0';
      end if;
      if bus_i.r.ready = '1' then
        bus_v.r.valid := '0';
      end if;

      -- If we indicated to the master that we were ready for a transaction on
      -- any of the incoming channels, we must latch any incoming requests. If
      -- we're ready but there is no incoming request this becomes don't-care.
      if bus_v.aw.ready = '1' then
        awl := bus_i.aw;
      end if;
      if bus_v.w.ready = '1' then
        wl := bus_i.w;
      end if;
      if bus_v.ar.ready = '1' then
        arl := bus_i.ar;
      end if;

      -------------------------------------------------------------------------
      -- Handle interrupts
      -------------------------------------------------------------------------
      -- No incoming interrupts; request signal is always released.
      bus_v.u.irq := '0';

      -------------------------------------------------------------------------
      -- Handle MMIO fields
      -------------------------------------------------------------------------
      -- We're ready for a write/read when all the respective channels (or
      -- their holding registers) are ready/waiting for us.
      if awl.valid = '1' and wl.valid = '1' then
        if bus_v.b.valid = '0' then
          w_req := true; -- Request valid and response register empty.
        else
          w_lreq := true; -- Request valid, but response register is busy.
        end if;
      end if;
      if arl.valid = '1' then
        if bus_v.r.valid = '0' then
          r_req := true; -- Request valid and response register empty.
        else
          r_lreq := true; -- Request valid, but response register is busy.
        end if;
      end if;

      -- Capture request inputs into more consistently named variables.
      w_addr := awl.addr;
      for b in w_strb'range loop
        w_strb(b) := wl.strb(b / 8);
      end loop;
      w_data := wl.data and w_strb;
      r_addr := arl.addr;

      -------------------------------------------------------------------------
      -- Generated field logic
      -------------------------------------------------------------------------

      -- Pre-bus logic for field AddStb: AddStb.

      -- Handle post-write invalidation for field AddStb one cycle after the
      -- write occurs.
      if f_AddStb_r((0)).inval = '1' then
        f_AddStb_r((0)).d := (others => '0');
        f_AddStb_r((0)).v := '0';
      end if;
      f_AddStb_r((0)).inval := '0';

      -- Pre-bus logic for field Sum: Sum.

      -- Handle hardware write for field Sum: status.
      f_Sum_r((0)).d := f_Sum_i.write_data;
      f_Sum_r((0)).v := '1';

      -- Pre-bus logic for field AS: AS.

      -- Handle ready control input for field AS.
      if f_AS_i.ready = '1' then
        f_AS_r((0)).d := (others => '0');
        f_AS_r((0)).v := '0';
      end if;

      -- Pre-bus logic for field BS: BS.

      -- Handle ready control input for field BS.
      if f_BS_i.ready = '1' then
        f_BS_r((0)).d := (others => '0');
        f_BS_r((0)).v := '0';
      end if;

      -- Pre-bus logic for field CS: CS.

      -- Handle ready control input for field CS.
      if f_CS_i.ready = '1' then
        f_CS_r((0)).d := (others => '0');
        f_CS_r((0)).v := '0';
      end if;

      -- Pre-bus logic for field Sum_Stream: Sum_Stream.

      -- Handle hardware write for field Sum_Stream: stream. Also handle
      -- post-write operation: validate.
      if f_Sum_Stream_i.valid = '1' and f_Sum_Stream_r((0)).v = '0' then
        f_Sum_Stream_r((0)).d := f_Sum_Stream_i.data;
        f_Sum_Stream_r((0)).v := '1';
      end if;

      -------------------------------------------------------------------------
      -- Bus read logic
      -------------------------------------------------------------------------

      -- Construct the subaddresses for read mode.
      subaddr_none(0) := '0';

      -- Read address decoder.
      if r_addr(31 downto 5) = "000000000000000000000000000" then
        case r_addr(4 downto 2) is
          when "000" =>
            -- r_addr = 000000000000000000000000000000--

            if r_req then

              -- Clear holding register location prior to read.
              r_hold := (others => '0');

            end if;

            -- Read logic for field A: A.

            if r_req then
              tmp_data20 := r_hold(19 downto 0);
            end if;
            if r_req then

              -- Regular access logic. Read mode: enabled.
              tmp_data20 := f_A_r((0)).d;
              r_ack := true;

            end if;
            if r_req then
              r_hold(19 downto 0) := tmp_data20;
            end if;

            -- Read logic for field B: B.

            if r_req then
              tmp_data10 := r_hold(29 downto 20);
            end if;
            if r_req then

              -- Regular access logic. Read mode: enabled.
              tmp_data10 := f_B_r((0)).d;
              r_ack := true;

            end if;
            if r_req then
              r_hold(29 downto 20) := tmp_data10;
            end if;

            -- Read logic for field C: C.

            if r_req then
              tmp_data8 := r_hold(37 downto 30);
            end if;
            if r_req then

              -- Regular access logic. Read mode: enabled.
              tmp_data8 := f_C_r((0)).d;
              r_ack := true;

            end if;
            if r_req then
              r_hold(37 downto 30) := tmp_data8;
            end if;

            -- Read logic for block A_reg_low: block containing bits 31..0 of
            -- register `A_reg` (`A`).
            if r_req then

              r_data := r_hold(31 downto 0);
              r_multi := '1';

            end if;

          when "001" =>
            -- r_addr = 000000000000000000000000000001--

            -- Read logic for block A_reg_high: block containing bits 63..32 of
            -- register `A_reg` (`A`).
            if r_req then

              r_data := r_hold(63 downto 32);
              if r_multi = '1' then
                r_ack := true;
              else
                r_nack := true;
              end if;
              r_multi := '0';

            end if;

          when "011" =>
            -- r_addr = 000000000000000000000000000011--

            if r_req then

              -- Clear holding register location prior to read.
              r_hold := (others => '0');

            end if;

            -- Read logic for field Sum: Sum.

            if r_req then
              tmp_data21 := r_hold(20 downto 0);
            end if;
            if r_req then

              -- Regular access logic. Read mode: enabled.
              tmp_data21 := f_Sum_r((0)).d;
              r_ack := true;

            end if;
            if r_req then
              r_hold(20 downto 0) := tmp_data21;
            end if;

            -- Read logic for block Sum_reg: block containing bits 31..0 of
            -- register `Sum_reg` (`SUM`).
            if r_req then

              r_data := r_hold(31 downto 0);
              r_multi := '0';

            end if;

          when "110" =>
            -- r_addr = 000000000000000000000000000110--

            if r_req then

              -- Clear holding register location prior to read.
              r_hold := (others => '0');

            end if;

            -- Read logic for field Sum_Stream: Sum_Stream.

            if r_req then
              tmp_data21 := r_hold(20 downto 0);
            end if;
            if r_req then

              -- Regular access logic. Read mode: enabled.
              tmp_data21 := f_Sum_Stream_r((0)).d;
              r_ack := true;

              -- Handle post-read operation: invalidate.
              f_Sum_Stream_r((0)).d := (others => '0');
              f_Sum_Stream_r((0)).v := '0';

            end if;
            if r_req then
              r_hold(20 downto 0) := tmp_data21;
            end if;

            -- Read logic for block Sum_Stream_reg: block containing bits 31..0
            -- of register `Sum_Stream_reg` (`SUM_STREAM`).
            if r_req then

              r_data := r_hold(31 downto 0);
              r_multi := '0';

            end if;

          when others =>
            null;
        end case;
      end if;

      -------------------------------------------------------------------------
      -- Bus write logic
      -------------------------------------------------------------------------

      -- Construct the subaddresses for write mode.
      subaddr_none(0) := '0';

      -- Write address decoder.
      if w_addr(31 downto 5) = "000000000000000000000000000" then
        case w_addr(4 downto 2) is
          when "000" =>
            -- w_addr = 000000000000000000000000000000--

            -- Write logic for block A_reg_low: block containing bits 31..0 of
            -- register `A_reg` (`A`).
            if w_req or w_lreq then
              w_hold(31 downto 0) := w_data;
              w_hstb(31 downto 0) := w_strb;
              w_multi := '1';
            end if;
            if w_req then
              w_ack := true;
            end if;

          when "001" =>
            -- w_addr = 000000000000000000000000000001--

            -- Write logic for block A_reg_high: block containing bits 63..32 of
            -- register `A_reg` (`A`).
            if w_req or w_lreq then
              w_hold(63 downto 32) := w_data;
              w_hstb(63 downto 32) := w_strb;
              w_multi := '0';
            end if;

            -- Write logic for field A: A.

            tmp_data20 := w_hold(19 downto 0);
            tmp_strb20 := w_hstb(19 downto 0);
            if w_req then

              -- Regular access logic. Write mode: masked.

              f_A_r((0)).d := (f_A_r((0)).d and not tmp_strb20) or tmp_data20;
              w_ack := true;

            end if;

            -- Write logic for field B: B.

            tmp_data10 := w_hold(29 downto 20);
            tmp_strb10 := w_hstb(29 downto 20);
            if w_req then

              -- Regular access logic. Write mode: masked.

              f_B_r((0)).d := (f_B_r((0)).d and not tmp_strb10) or tmp_data10;
              w_ack := true;

            end if;

            -- Write logic for field C: C.

            tmp_data8 := w_hold(37 downto 30);
            tmp_strb8 := w_hstb(37 downto 30);
            if w_req then

              -- Regular access logic. Write mode: masked.

              f_C_r((0)).d := (f_C_r((0)).d and not tmp_strb8) or tmp_data8;
              w_ack := true;

            end if;

          when "010" =>
            -- w_addr = 000000000000000000000000000010--

            -- Write logic for block AddStb_reg: block containing bits 31..0 of
            -- register `AddStb_reg` (`ADDSTB`).
            if w_req or w_lreq then
              w_hold(31 downto 0) := w_data;
              w_hstb(31 downto 0) := w_strb;
              w_multi := '0';
            end if;

            -- Write logic for field AddStb: AddStb.

            tmp_data32 := w_hold(31 downto 0);
            tmp_strb32 := w_hstb(31 downto 0);
            if w_req then

              -- Regular access logic. Write mode: enabled.

              f_AddStb_r((0)).d := tmp_data32;
              w_ack := true;

              -- Handle post-write operation: invalidate.
              f_AddStb_r((0)).v := '1';
              f_AddStb_r((0)).inval := '1';

            end if;

          when "100" =>
            -- w_addr = 000000000000000000000000000100--

            -- Write logic for block AS_reg_low: block containing bits 31..0 of
            -- register `AS_reg` (`AS`).
            if w_req or w_lreq then
              w_hold(31 downto 0) := w_data;
              w_hstb(31 downto 0) := w_strb;
              w_multi := '1';
            end if;
            if w_req then
              w_ack := true;
            end if;

          when "101" =>
            -- w_addr = 000000000000000000000000000101--

            -- Write logic for block AS_reg_high: block containing bits 63..32
            -- of register `AS_reg` (`AS`).
            if w_req or w_lreq then
              w_hold(63 downto 32) := w_data;
              w_hstb(63 downto 32) := w_strb;
              w_multi := '0';
            end if;

            -- Write logic for field AS: AS.

            tmp_data20 := w_hold(19 downto 0);
            tmp_strb20 := w_hstb(19 downto 0);
            if w_req then

              -- Regular access logic. Write mode: invalid.

              if f_AS_r((0)).v = '0' then
                f_AS_r((0)).d := tmp_data20;
                w_ack := true;

                -- Handle post-write operation: validate.
                f_AS_r((0)).v := '1';

              else
                w_ack := true;
              end if;

            end if;

            -- Write logic for field BS: BS.

            tmp_data10 := w_hold(29 downto 20);
            tmp_strb10 := w_hstb(29 downto 20);
            if w_req then

              -- Regular access logic. Write mode: invalid.

              if f_BS_r((0)).v = '0' then
                f_BS_r((0)).d := tmp_data10;
                w_ack := true;

                -- Handle post-write operation: validate.
                f_BS_r((0)).v := '1';

              else
                w_ack := true;
              end if;

            end if;

            -- Write logic for field CS: CS.

            tmp_data8 := w_hold(37 downto 30);
            tmp_strb8 := w_hstb(37 downto 30);
            if w_req then

              -- Regular access logic. Write mode: invalid.

              if f_CS_r((0)).v = '0' then
                f_CS_r((0)).d := tmp_data8;
                w_ack := true;

                -- Handle post-write operation: validate.
                f_CS_r((0)).v := '1';

              else
                w_ack := true;
              end if;

            end if;

          when others =>
            null;
        end case;
      end if;

      -------------------------------------------------------------------------
      -- Generated field logic
      -------------------------------------------------------------------------

      -- Post-bus logic for field A: A.

      -- Handle reset for field A.
      if reset = '1' then
        f_A_r((0)).d := (others => '0');
        f_A_r((0)).v := '0';
      end if;
      -- Assign the read outputs for field A.
      g_Add_o.f_A.data <= f_A_r((0)).d;

      -- Post-bus logic for field B: B.

      -- Handle reset for field B.
      if reset = '1' then
        f_B_r((0)).d := (others => '0');
        f_B_r((0)).v := '0';
      end if;
      -- Assign the read outputs for field B.
      g_Add_o.f_B.data <= f_B_r((0)).d;

      -- Post-bus logic for field C: C.

      -- Handle reset for field C.
      if reset = '1' then
        f_C_r((0)).d := (others => '0');
        f_C_r((0)).v := '0';
      end if;
      -- Assign the read outputs for field C.
      g_Add_o.f_C.data <= f_C_r((0)).d;

      -- Post-bus logic for field AddStb: AddStb.

      -- Handle reset for field AddStb.
      if reset = '1' then
        f_AddStb_r((0)).d := "00000000000000000000000000000000";
        f_AddStb_r((0)).v := '1';
        f_AddStb_r((0)).inval := '0';
      end if;
      -- Assign the read outputs for field AddStb.
      g_Add_o.f_AddStb.data <= f_AddStb_r((0)).d;

      -- Post-bus logic for field AS: AS.

      -- Handle reset for field AS.
      if reset = '1' then
        f_AS_r((0)).d := (others => '0');
        f_AS_r((0)).v := '0';
      end if;
      -- Assign the read outputs for field AS.
      f_AS_o.data <= f_AS_r((0)).d;
      f_AS_o.valid <= f_AS_r((0)).v;

      -- Post-bus logic for field BS: BS.

      -- Handle reset for field BS.
      if reset = '1' then
        f_BS_r((0)).d := (others => '0');
        f_BS_r((0)).v := '0';
      end if;
      -- Assign the read outputs for field BS.
      f_BS_o.data <= f_BS_r((0)).d;
      f_BS_o.valid <= f_BS_r((0)).v;

      -- Post-bus logic for field CS: CS.

      -- Handle reset for field CS.
      if reset = '1' then
        f_CS_r((0)).d := (others => '0');
        f_CS_r((0)).v := '0';
      end if;
      -- Assign the read outputs for field CS.
      f_CS_o.data <= f_CS_r((0)).d;
      f_CS_o.valid <= f_CS_r((0)).v;

      -- Post-bus logic for field Sum_Stream: Sum_Stream.

      -- Handle reset for field Sum_Stream.
      if reset = '1' then
        f_Sum_Stream_r((0)).d := (others => '0');
        f_Sum_Stream_r((0)).v := '0';
      end if;
      -- Assign the ready output for field Sum_Stream.
      f_Sum_Stream_o.ready <= not f_Sum_Stream_r((0)).v;

      -------------------------------------------------------------------------
      -- Boilerplate bus access logic
      -------------------------------------------------------------------------
      -- Perform the write action dictated by the field logic.
      if w_req and not w_block then

        -- Accept write requests by invalidating the request holding
        -- registers.
        awl.valid := '0';
        wl.valid := '0';

        -- Send the appropriate write response.
        bus_v.b.valid := '1';
        if w_nack then
          bus_v.b.resp := AXI4L_RESP_SLVERR;
        elsif w_ack then
          bus_v.b.resp := AXI4L_RESP_OKAY;
        else
          bus_v.b.resp := AXI4L_RESP_DECERR;
        end if;

      end if;

      -- Perform the read action dictated by the field logic.
      if r_req and not r_block then

        -- Accept read requests by invalidating the request holding
        -- registers.
        arl.valid := '0';

        -- Send the appropriate read response.
        bus_v.r.valid := '1';
        if r_nack then
          bus_v.r.resp := AXI4L_RESP_SLVERR;
        elsif r_ack then
          bus_v.r.resp := AXI4L_RESP_OKAY;
          bus_v.r.data := r_data;
        else
          bus_v.r.resp := AXI4L_RESP_DECERR;
        end if;

      end if;

      -- If we're at the end of a multi-word write, clear the write strobe
      -- holding register to prevent previously written data from leaking into
      -- later partial writes.
      if w_multi = '0' then
        w_hstb := (others => '0');
      end if;

      -- Mark the incoming channels as ready when their respective holding
      -- registers are empty.
      bus_v.aw.ready := not awl.valid;
      bus_v.w.ready := not wl.valid;
      bus_v.ar.ready := not arl.valid;

      -------------------------------------------------------------------------
      -- Handle AXI4-lite bus reset
      -------------------------------------------------------------------------
      -- Reset overrides everything, so it comes last. Note that field
      -- registers are *not* reset here; this would complicate code generation.
      -- Instead, the generated field logic blocks include reset logic for the
      -- field-specific registers.
      if reset = '1' then
        bus_v      := AXI4L32_S2M_RESET;
        awl        := AXI4LA_RESET;
        wl         := AXI4LW32_RESET;
        arl        := AXI4LA_RESET;
        w_hstb     := (others => '0');
        w_hold     := (others => '0');
        w_multi    := '0';
        r_multi    := '0';
        r_hold     := (others => '0');
      end if;

      bus_o <= bus_v;

    end if;
  end process;
end behavioral;
