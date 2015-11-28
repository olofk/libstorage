--
-- FIFO First word fall through adapter. Part of libstorage
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
use ieee.std_logic_1164.all;

entity fifo_fwft_adapter is
  port (
    clk            : in  std_ulogic;
    rst            : in  std_ulogic;
    fifo_rd_en_o   : out std_ulogic;
    fifo_rd_data_i : in  std_ulogic_vector;
    fifo_empty_i   : in  std_ulogic;
    rd_en_i        : in  std_ulogic;
    rd_data_o      : out std_ulogic_vector;
    empty_o        : out std_ulogic);
end entity;

architecture rtl of fifo_fwft_adapter is
  signal fifo_valid   : std_ulogic;
  signal middle_valid : std_ulogic;
  signal dout_valid   : std_ulogic;
  signal will_update_middle : std_ulogic;
  signal will_update_dout : std_ulogic;
  signal middle_dout : std_ulogic_vector(fifo_rd_data_i'range);
begin
   
  will_update_middle <= fifo_valid  and (middle_valid ?= will_update_dout);
  will_update_dout   <= (middle_valid or fifo_valid) and
                        (rd_en_i or not dout_valid);
  fifo_rd_en_o <= (not fifo_empty_i) and
                  not (middle_valid and dout_valid and fifo_valid);
  empty_o <= not dout_valid;

  p_main : process(clk)
  begin
    if rising_edge(clk) then
      if will_update_middle then
        middle_dout <= fifo_rd_data_i;
      end if;

      if will_update_dout then
        if middle_valid = '1' then
          rd_data_o <= middle_dout;
        else
          rd_data_o <= fifo_rd_data_i;
        end if;
      end if;

      if fifo_rd_en_o then
        fifo_valid <= '1';
      elsif will_update_middle or will_update_dout then
        fifo_valid <= '0';
      end if;
            
      if will_update_middle then
        middle_valid <= '1';
      elsif will_update_dout then
        middle_valid <= '0';
      end if;

      if will_update_dout then
        dout_valid <= '1';
      elsif rd_en_i then
        dout_valid <= '0';
      end if;

      if rst then
        fifo_valid <= '0';
        middle_valid <= '0';
        dout_valid <= '0';
      end if;
    end if;
  end process;
end architecture rtl;

