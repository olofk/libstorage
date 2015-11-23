--
-- First Word Fall Through FIFO. Part of libstorage
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

library libstorage_1;

entity fifo_fwft_generic is
  generic (
    type data_type;
    DEPTH : positive;
    FWFT  : boolean := false);
  port (
    clk       : in  std_ulogic;
    rst       : in  std_ulogic;
    rd_en_i   : in  std_ulogic;
    rd_data_o : out data_type;
    full_o    : out std_ulogic;
    wr_en_i   : in  std_ulogic;
    wr_data_i : in  data_type;
    empty_o   : out std_ulogic);
  
end entity fifo_fwft_generic;

architecture str of fifo_fwft_generic is

  
  --FWFT signals
  signal fifo_rd_data : data_type;
  signal fifo_rd_en   : std_ulogic;
  signal fifo_empty   : std_ulogic;

  signal fwft_rd_data : data_type;
  signal fwft_rd_en   : std_ulogic;
  signal fwft_empty   : std_ulogic;

begin

  fifo_rd_en <= fwft_rd_en   when FWFT else rd_en_i;
  rd_data_o  <= fwft_rd_data when FWFT else fifo_rd_data;
  empty_o    <= fwft_empty   when FWFT else fifo_empty;

  fifo : entity libstorage_1.fifo_generic
    generic map (
      data_type => data_type,
      DEPTH => DEPTH)
    port map (
      clk       => clk,
      rst       => rst,
      rd_en_i   => fifo_rd_en,
      rd_data_o => fifo_rd_data,
      empty_o   => fifo_empty,
      wr_en_i   => wr_en_i,
      wr_data_i => wr_data_i,
      full_o    => full_o);

  gen_fwft: if FWFT generate
    fifo_fwft_adapter: entity libstorage_1.fifo_fwft_adapter
      generic map (
        data_type => data_type)
      port map (
        clk            => clk,
        rst            => rst,
        fifo_rd_en_o   => fwft_rd_en,
        fifo_rd_data_i => fifo_rd_data,
        fifo_empty_i   => fifo_empty,
        rd_en_i        => rd_en_i,
        rd_data_o      => fwft_rd_data,
        empty_o        => fwft_empty);
  end generate gen_fwft;

end architecture str;
