-- Generated using vhdMMIO 0.0.3 (https://github.com/abs-tudelft/vhdmmio)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library work;
use work.vhdmmio_pkg.all;
use work.Main_pkg.all;

entity Main is
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

    -- AXI4-lite + interrupt request bus to the master.
    bus_i : in  axi4l32_m2s_type := AXI4L32_M2S_RESET;
    bus_o : out axi4l32_s2m_type := AXI4L32_S2M_RESET

  );
end Main;

architecture behavioral of Main is
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
    variable w_hold : std_logic_vector(31 downto 0) := (others => '0'); -- reg
    variable w_hstb : std_logic_vector(31 downto 0) := (others => '0'); -- reg

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
    variable r_hold  : std_logic_vector(31 downto 0) := (others => '0'); -- reg

    -- Physical read data. This is taken from r_hold based on which physical
    -- subregister is being read.
    variable r_data  : std_logic_vector(31 downto 0);

    -- Subaddress variables, used to index within large fields like memories and
    -- AXI passthroughs.
    variable subaddr_none         : std_logic_vector(0 downto 0);

    -- Private declarations for field C1: C1.
    type f_C1_r_type is record
      d : std_logic_vector(6 downto 0);
      v : std_logic;
    end record;
    constant F_C1_R_RESET : f_C1_r_type := (
      d => (others => '0'),
      v => '0'
    );
    type f_C1_r_array is array (natural range <>) of f_C1_r_type;
    variable f_C1_r : f_C1_r_array(0 to 0) := (others => F_C1_R_RESET);

    -- Private declarations for field C2: C2.
    type f_C2_r_type is record
      d : std_logic_vector(8 downto 0);
      v : std_logic;
    end record;
    constant F_C2_R_RESET : f_C2_r_type := (
      d => (others => '0'),
      v => '0'
    );
    type f_C2_r_array is array (natural range <>) of f_C2_r_type;
    variable f_C2_r : f_C2_r_array(0 to 0) := (others => F_C2_R_RESET);

    -- Private declarations for field C3: C3.
    type f_C3_r_type is record
      d : std_logic_vector(11 downto 0);
      v : std_logic;
    end record;
    constant F_C3_R_RESET : f_C3_r_type := (
      d => (others => '0'),
      v => '0'
    );
    type f_C3_r_array is array (natural range <>) of f_C3_r_type;
    variable f_C3_r : f_C3_r_array(0 to 0) := (others => F_C3_R_RESET);

    -- Private declarations for field S1: S1.
    type f_S1_r_type is record
      d : std_logic_vector(6 downto 0);
      v : std_logic;
    end record;
    constant F_S1_R_RESET : f_S1_r_type := (
      d => (others => '0'),
      v => '0'
    );
    type f_S1_r_array is array (natural range <>) of f_S1_r_type;
    variable f_S1_r : f_S1_r_array(0 to 0) := (others => F_S1_R_RESET);

    -- Private declarations for field S2: S2.
    type f_S2_r_type is record
      d : std_logic_vector(8 downto 0);
      v : std_logic;
    end record;
    constant F_S2_R_RESET : f_S2_r_type := (
      d => (others => '0'),
      v => '0'
    );
    type f_S2_r_array is array (natural range <>) of f_S2_r_type;
    variable f_S2_r : f_S2_r_array(0 to 0) := (others => F_S2_R_RESET);

    -- Private declarations for field S3: S3.
    type f_S3_r_type is record
      d : std_logic_vector(11 downto 0);
      v : std_logic;
    end record;
    constant F_S3_R_RESET : f_S3_r_type := (
      d => (others => '0'),
      v => '0'
    );
    type f_S3_r_array is array (natural range <>) of f_S3_r_type;
    variable f_S3_r : f_S3_r_array(0 to 0) := (others => F_S3_R_RESET);

    -- Temporary variables for the field templates.
    variable tmp_data7   : std_logic_vector(6 downto 0);
    variable tmp_strb7   : std_logic_vector(6 downto 0);
    variable tmp_data9   : std_logic_vector(8 downto 0);
    variable tmp_strb9   : std_logic_vector(8 downto 0);
    variable tmp_data12  : std_logic_vector(11 downto 0);
    variable tmp_strb12  : std_logic_vector(11 downto 0);

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

      -- Pre-bus logic for field S1: S1.

      -- Handle hardware write for field S1: status.
      f_S1_r((0)).d := f_S1_i.write_data;
      f_S1_r((0)).v := '1';

      -- Pre-bus logic for field S2: S2.

      -- Handle hardware write for field S2: status.
      f_S2_r((0)).d := f_S2_i.write_data;
      f_S2_r((0)).v := '1';

      -- Pre-bus logic for field S3: S3.

      -- Handle hardware write for field S3: status.
      f_S3_r((0)).d := f_S3_i.write_data;
      f_S3_r((0)).v := '1';

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

            -- Read logic for field C1: C1.

            if r_req then
              tmp_data7 := r_hold(6 downto 0);
            end if;
            if r_req then

              -- Regular access logic. Read mode: enabled.
              tmp_data7 := f_C1_r((0)).d;
              r_ack := true;

            end if;
            if r_req then
              r_hold(6 downto 0) := tmp_data7;
            end if;

            -- Read logic for block C1_reg: block containing bits 31..0 of
            -- register `C1_reg` (`C1`).
            if r_req then

              r_data := r_hold(31 downto 0);
              r_multi := '0';

            end if;

          when "001" =>
            -- r_addr = 000000000000000000000000000001--

            if r_req then

              -- Clear holding register location prior to read.
              r_hold := (others => '0');

            end if;

            -- Read logic for field C2: C2.

            if r_req then
              tmp_data9 := r_hold(8 downto 0);
            end if;
            if r_req then

              -- Regular access logic. Read mode: enabled.
              tmp_data9 := f_C2_r((0)).d;
              r_ack := true;

            end if;
            if r_req then
              r_hold(8 downto 0) := tmp_data9;
            end if;

            -- Read logic for block C2_reg: block containing bits 31..0 of
            -- register `C2_reg` (`C2`).
            if r_req then

              r_data := r_hold(31 downto 0);
              r_multi := '0';

            end if;

          when "010" =>
            -- r_addr = 000000000000000000000000000010--

            if r_req then

              -- Clear holding register location prior to read.
              r_hold := (others => '0');

            end if;

            -- Read logic for field C3: C3.

            if r_req then
              tmp_data12 := r_hold(11 downto 0);
            end if;
            if r_req then

              -- Regular access logic. Read mode: enabled.
              tmp_data12 := f_C3_r((0)).d;
              r_ack := true;

            end if;
            if r_req then
              r_hold(11 downto 0) := tmp_data12;
            end if;

            -- Read logic for block C3_reg: block containing bits 31..0 of
            -- register `C3_reg` (`C3`).
            if r_req then

              r_data := r_hold(31 downto 0);
              r_multi := '0';

            end if;

          when "011" =>
            -- r_addr = 000000000000000000000000000011--

            if r_req then

              -- Clear holding register location prior to read.
              r_hold := (others => '0');

            end if;

            -- Read logic for field S1: S1.

            if r_req then
              tmp_data7 := r_hold(6 downto 0);
            end if;
            if r_req then

              -- Regular access logic. Read mode: enabled.
              tmp_data7 := f_S1_r((0)).d;
              r_ack := true;

            end if;
            if r_req then
              r_hold(6 downto 0) := tmp_data7;
            end if;

            -- Read logic for block S1_reg: block containing bits 31..0 of
            -- register `S1_reg` (`S1`).
            if r_req then

              r_data := r_hold(31 downto 0);
              r_multi := '0';

            end if;

          when "100" =>
            -- r_addr = 000000000000000000000000000100--

            if r_req then

              -- Clear holding register location prior to read.
              r_hold := (others => '0');

            end if;

            -- Read logic for field S2: S2.

            if r_req then
              tmp_data9 := r_hold(8 downto 0);
            end if;
            if r_req then

              -- Regular access logic. Read mode: enabled.
              tmp_data9 := f_S2_r((0)).d;
              r_ack := true;

            end if;
            if r_req then
              r_hold(8 downto 0) := tmp_data9;
            end if;

            -- Read logic for block S2_reg: block containing bits 31..0 of
            -- register `S2_reg` (`S2`).
            if r_req then

              r_data := r_hold(31 downto 0);
              r_multi := '0';

            end if;

          when "101" =>
            -- r_addr = 000000000000000000000000000101--

            if r_req then

              -- Clear holding register location prior to read.
              r_hold := (others => '0');

            end if;

            -- Read logic for field S3: S3.

            if r_req then
              tmp_data12 := r_hold(11 downto 0);
            end if;
            if r_req then

              -- Regular access logic. Read mode: enabled.
              tmp_data12 := f_S3_r((0)).d;
              r_ack := true;

            end if;
            if r_req then
              r_hold(11 downto 0) := tmp_data12;
            end if;

            -- Read logic for block S3_reg: block containing bits 31..0 of
            -- register `S3_reg` (`S3`).
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
      if w_addr(31 downto 4) = "0000000000000000000000000000" then
        case w_addr(3 downto 2) is
          when "00" =>
            -- w_addr = 000000000000000000000000000000--

            -- Write logic for block C1_reg: block containing bits 31..0 of
            -- register `C1_reg` (`C1`).
            if w_req or w_lreq then
              w_hold(31 downto 0) := w_data;
              w_hstb(31 downto 0) := w_strb;
              w_multi := '0';
            end if;

            -- Write logic for field C1: C1.

            tmp_data7 := w_hold(6 downto 0);
            tmp_strb7 := w_hstb(6 downto 0);
            if w_req then

              -- Regular access logic. Write mode: masked.

              f_C1_r((0)).d := (f_C1_r((0)).d and not tmp_strb7) or tmp_data7;
              w_ack := true;

            end if;

          when "01" =>
            -- w_addr = 000000000000000000000000000001--

            -- Write logic for block C2_reg: block containing bits 31..0 of
            -- register `C2_reg` (`C2`).
            if w_req or w_lreq then
              w_hold(31 downto 0) := w_data;
              w_hstb(31 downto 0) := w_strb;
              w_multi := '0';
            end if;

            -- Write logic for field C2: C2.

            tmp_data9 := w_hold(8 downto 0);
            tmp_strb9 := w_hstb(8 downto 0);
            if w_req then

              -- Regular access logic. Write mode: masked.

              f_C2_r((0)).d := (f_C2_r((0)).d and not tmp_strb9) or tmp_data9;
              w_ack := true;

            end if;

          when "10" =>
            -- w_addr = 000000000000000000000000000010--

            -- Write logic for block C3_reg: block containing bits 31..0 of
            -- register `C3_reg` (`C3`).
            if w_req or w_lreq then
              w_hold(31 downto 0) := w_data;
              w_hstb(31 downto 0) := w_strb;
              w_multi := '0';
            end if;

            -- Write logic for field C3: C3.

            tmp_data12 := w_hold(11 downto 0);
            tmp_strb12 := w_hstb(11 downto 0);
            if w_req then

              -- Regular access logic. Write mode: masked.

              f_C3_r((0)).d := (f_C3_r((0)).d and not tmp_strb12) or tmp_data12;
              w_ack := true;

            end if;

          when others =>
            null;
        end case;
      end if;

      -------------------------------------------------------------------------
      -- Generated field logic
      -------------------------------------------------------------------------

      -- Post-bus logic for field C1: C1.

      -- Handle reset for field C1.
      if reset = '1' then
        f_C1_r((0)).d := (others => '0');
        f_C1_r((0)).v := '0';
      end if;
      -- Assign the read outputs for field C1.
      f_C1_o.data <= f_C1_r((0)).d;

      -- Post-bus logic for field C2: C2.

      -- Handle reset for field C2.
      if reset = '1' then
        f_C2_r((0)).d := (others => '0');
        f_C2_r((0)).v := '0';
      end if;
      -- Assign the read outputs for field C2.
      f_C2_o.data <= f_C2_r((0)).d;

      -- Post-bus logic for field C3: C3.

      -- Handle reset for field C3.
      if reset = '1' then
        f_C3_r((0)).d := (others => '0');
        f_C3_r((0)).v := '0';
      end if;
      -- Assign the read outputs for field C3.
      f_C3_o.data <= f_C3_r((0)).d;

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
