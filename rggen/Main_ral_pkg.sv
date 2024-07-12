package Main_ral_pkg;
  import uvm_pkg::*;
  import rggen_ral_pkg::*;
  `include "uvm_macros.svh"
  `include "rggen_ral_macros.svh"
  class Subblock_Add_reg_model extends rggen_ral_reg;
    rand rggen_ral_field A;
    rand rggen_ral_field B;
    rand rggen_ral_field C;
    rand rggen_ral_field Sum;
    function new(string name);
      super.new(name, 64, 0);
    endfunction
    function void build();
      `rggen_ral_create_field(A, 0, 20, "WO", 0, 20'h00000, 1, -1, "")
      `rggen_ral_create_field(B, 20, 10, "WO", 0, 10'h000, 1, -1, "")
      `rggen_ral_create_field(C, 30, 8, "WO", 0, 8'h00, 1, -1, "")
      `rggen_ral_create_field(Sum, 38, 21, "RO", 1, 21'h000000, 0, -1, "")
    endfunction
  endclass
  class Subblock_reg_file_model extends rggen_ral_reg_file;
    rand Subblock_Add_reg_model Add;
    function new(string name);
      super.new(name, 4, 0);
    endfunction
    function void build();
      `rggen_ral_create_reg(Add, '{}, 7'h00, "RW", "g_Add.u_register")
    endfunction
  endclass
  class C1_reg_model extends rggen_ral_reg;
    rand rggen_ral_field C1;
    function new(string name);
      super.new(name, 32, 0);
    endfunction
    function void build();
      `rggen_ral_create_field(C1, 0, 7, "RW", 0, 7'h00, 1, -1, "")
    endfunction
  endclass
  class C2_reg_model extends rggen_ral_reg;
    rand rggen_ral_field C2;
    function new(string name);
      super.new(name, 32, 0);
    endfunction
    function void build();
      `rggen_ral_create_field(C2, 0, 9, "RW", 0, 9'h000, 1, -1, "")
    endfunction
  endclass
  class C3_reg_model extends rggen_ral_reg;
    rand rggen_ral_field C3;
    function new(string name);
      super.new(name, 32, 0);
    endfunction
    function void build();
      `rggen_ral_create_field(C3, 0, 12, "RW", 0, 12'h000, 1, -1, "")
    endfunction
  endclass
  class S1_reg_model extends rggen_ral_reg;
    rand rggen_ral_field S1;
    function new(string name);
      super.new(name, 32, 0);
    endfunction
    function void build();
      `rggen_ral_create_field(S1, 0, 7, "RO", 1, 7'h00, 0, -1, "")
    endfunction
  endclass
  class S2_reg_model extends rggen_ral_reg;
    rand rggen_ral_field S2;
    function new(string name);
      super.new(name, 32, 0);
    endfunction
    function void build();
      `rggen_ral_create_field(S2, 0, 9, "RO", 1, 9'h000, 0, -1, "")
    endfunction
  endclass
  class S3_reg_model extends rggen_ral_reg;
    rand rggen_ral_field S3;
    function new(string name);
      super.new(name, 32, 0);
    endfunction
    function void build();
      `rggen_ral_create_field(S3, 0, 12, "RO", 1, 12'h000, 0, -1, "")
    endfunction
  endclass
  class CA_reg_model extends rggen_ral_reg;
    rand rggen_ral_field C;
    function new(string name);
      super.new(name, 32, 0);
    endfunction
    function void build();
      `rggen_ral_create_field(C, 0, 8, "RW", 0, 8'h00, 1, -1, "")
    endfunction
  endclass
  class SA_reg_model extends rggen_ral_reg;
    rand rggen_ral_field S;
    function new(string name);
      super.new(name, 32, 0);
    endfunction
    function void build();
      `rggen_ral_create_field(S, 0, 8, "RO", 1, 8'h00, 0, -1, "")
    endfunction
  endclass
  class Counter_reg_model extends rggen_ral_reg;
    rand rggen_ral_field Value;
    function new(string name);
      super.new(name, 64, 0);
    endfunction
    function void build();
      `rggen_ral_create_field(Value, 0, 33, "RO", 1, 33'h000000000, 1, -1, "")
    endfunction
  endclass
  class Mask_reg_model extends rggen_ral_reg;
    rand rggen_ral_field Mask;
    function new(string name);
      super.new(name, 32, 0);
    endfunction
    function void build();
      `rggen_ral_create_field(Mask, 0, 16, "RW", 0, 16'h0000, 1, -1, "")
    endfunction
  endclass
  class Version_reg_model extends rggen_ral_reg;
    rand rggen_ral_field Version;
    function new(string name);
      super.new(name, 32, 0);
    endfunction
    function void build();
      `rggen_ral_create_field(Version, 0, 24, "RO", 0, 24'h010102, 1, -1, "")
    endfunction
  endclass
  class Main_block_model extends rggen_ral_block;
    rand Subblock_reg_file_model Subblock;
    rand C1_reg_model C1;
    rand C2_reg_model C2;
    rand C3_reg_model C3;
    rand S1_reg_model S1;
    rand S2_reg_model S2;
    rand S3_reg_model S3;
    rand CA_reg_model CA[10];
    rand SA_reg_model SA[10];
    rand Counter_reg_model Counter;
    rand Mask_reg_model Mask;
    rand Version_reg_model Version;
    function new(string name);
      super.new(name, 4, 0);
    endfunction
    function void build();
      `rggen_ral_create_reg_file(Subblock, '{}, 7'h00, "g_Subblock")
      `rggen_ral_create_reg(C1, '{}, 7'h08, "RW", "g_C1.u_register")
      `rggen_ral_create_reg(C2, '{}, 7'h0c, "RW", "g_C2.u_register")
      `rggen_ral_create_reg(C3, '{}, 7'h10, "RW", "g_C3.u_register")
      `rggen_ral_create_reg(S1, '{}, 7'h14, "RO", "g_S1.u_register")
      `rggen_ral_create_reg(S2, '{}, 7'h18, "RO", "g_S2.u_register")
      `rggen_ral_create_reg(S3, '{}, 7'h1c, "RO", "g_S3.u_register")
      `rggen_ral_create_reg(CA[0], '{0}, 7'h20, "RW", "g_CA.g[0].u_register")
      `rggen_ral_create_reg(CA[1], '{1}, 7'h24, "RW", "g_CA.g[1].u_register")
      `rggen_ral_create_reg(CA[2], '{2}, 7'h28, "RW", "g_CA.g[2].u_register")
      `rggen_ral_create_reg(CA[3], '{3}, 7'h2c, "RW", "g_CA.g[3].u_register")
      `rggen_ral_create_reg(CA[4], '{4}, 7'h30, "RW", "g_CA.g[4].u_register")
      `rggen_ral_create_reg(CA[5], '{5}, 7'h34, "RW", "g_CA.g[5].u_register")
      `rggen_ral_create_reg(CA[6], '{6}, 7'h38, "RW", "g_CA.g[6].u_register")
      `rggen_ral_create_reg(CA[7], '{7}, 7'h3c, "RW", "g_CA.g[7].u_register")
      `rggen_ral_create_reg(CA[8], '{8}, 7'h40, "RW", "g_CA.g[8].u_register")
      `rggen_ral_create_reg(CA[9], '{9}, 7'h44, "RW", "g_CA.g[9].u_register")
      `rggen_ral_create_reg(SA[0], '{0}, 7'h48, "RO", "g_SA.g[0].u_register")
      `rggen_ral_create_reg(SA[1], '{1}, 7'h4c, "RO", "g_SA.g[1].u_register")
      `rggen_ral_create_reg(SA[2], '{2}, 7'h50, "RO", "g_SA.g[2].u_register")
      `rggen_ral_create_reg(SA[3], '{3}, 7'h54, "RO", "g_SA.g[3].u_register")
      `rggen_ral_create_reg(SA[4], '{4}, 7'h58, "RO", "g_SA.g[4].u_register")
      `rggen_ral_create_reg(SA[5], '{5}, 7'h5c, "RO", "g_SA.g[5].u_register")
      `rggen_ral_create_reg(SA[6], '{6}, 7'h60, "RO", "g_SA.g[6].u_register")
      `rggen_ral_create_reg(SA[7], '{7}, 7'h64, "RO", "g_SA.g[7].u_register")
      `rggen_ral_create_reg(SA[8], '{8}, 7'h68, "RO", "g_SA.g[8].u_register")
      `rggen_ral_create_reg(SA[9], '{9}, 7'h6c, "RO", "g_SA.g[9].u_register")
      `rggen_ral_create_reg(Counter, '{}, 7'h70, "RO", "g_Counter.u_register")
      `rggen_ral_create_reg(Mask, '{}, 7'h78, "RW", "g_Mask.u_register")
      `rggen_ral_create_reg(Version, '{}, 7'h7c, "RO", "g_Version.u_register")
    endfunction
  endclass
endpackage
