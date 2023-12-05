library ieee;
   use ieee.std_logic_1164.all;


package spi_wb_bridge_pkg is

   -- Currently no block can return RETRY, so there is no need to support it in firmware.
   type t_status is (SUCCESS, INVALID_CRC, BUS_ERROR, BUS_RETRY);
   function to_status(slv : std_logic_vector(7 downto 0)) return t_status;
   function to_slv(st : t_status) return std_logic_vector;
   function to_str(st : t_status) return string;

end package;


package body spi_wb_bridge_pkg is

   function to_status(slv : std_logic_vector(7 downto 0)) return t_status is
   begin
      if slv = "00000000" then
         return SUCCESS;
      elsif slv = "00000001" then
         return INVALID_CRC;
      elsif slv = "00000010" then
         return BUS_ERROR;
      elsif slv = "00000011" then
         return BUS_RETRY;
      else
         report "can't convert " & to_string(slv) & " to status" severity failure;
      end if;
   end function;


   function to_slv(st : t_status) return std_logic_vector is
      variable ret : std_logic_vector(7 downto 0);
   begin
      if st = SUCCESS then
         ret := (others => '0');
      elsif st = INVALID_CRC then
         ret := "00000001";
      elsif st = BUS_ERROR then
         ret := "00000010";
      elsif st = BUS_RETRY then
         ret := "00000011";
      end if;
      return ret;
   end function;


   function to_str(st : t_status) return string is
   begin
      if st = SUCCESS then
         return "SUCCESS";
      elsif st = INVALID_CRC then
         return "INVALID_CRC";
      elsif st = BUS_ERROR then
         return "BUS_ERROR";
      elsif st = BUS_RETRY then
         return "BUS_RETRY";
      end if;
   end function;

end package body;
