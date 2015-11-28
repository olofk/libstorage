--
-- Dual port RAM. Part of libstorage
--
-- Copyright (C) 2015  Olof Kindgren <olof.kindgren@gmail.com>
--
-- Permission to use, copy, modify, and/or distribute this software for any
-- purpose with or without fee is hereby granted, provided that the above
-- copyright notice and this permission notice appear in all copies.
--
-- THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
-- WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
-- MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
-- ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
-- WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
-- ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
-- OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
--
library ieee;
use ieee.math_real.all;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

library libstorage_1;
use libstorage_1.libstorage_pkg.all;

entity dpram_generic is
  
  generic (
    DEPTH : positive);
  port (
    clk       : in  std_ulogic;
    rd_en_i   : in  std_ulogic;
    rd_addr_i : in  unsigned(clog2(DEPTH)-1 downto 0);
    rd_data_o : out std_ulogic_vector;
    wr_en_i   : in  std_ulogic;
    wr_addr_i : in  unsigned(clog2(DEPTH)-1 downto 0);
    wr_data_i : in  std_ulogic_vector);

end entity dpram_generic;

architecture rtl of dpram_generic is

  signal mem : t_mem(0 to DEPTH-1)(wr_data_i'range);
  signal wr_data_i_r : std_logic_vector(wr_data_i'range);

begin

  assert is_pow2(DEPTH) report "DEPTH must be 2^n" severity failure;

  p_main : process(clk)
  begin
    if rising_edge(clk) then

      if wr_en_i then
        mem(to_integer(wr_addr_i)) <= wr_data_i;
      end if;

      if rd_en_i then
        wr_data_i_r <= wr_data_i;
        rd_data_o <= mem(to_integer(rd_addr_i));
      end if;

      if (rd_addr_i = wr_addr_i) and (rd_en_i and wr_en_i) = '1' then
        rd_data_o <= wr_data_i_r;
      end if;

    end if;
  end process;
  
end architecture rtl;
