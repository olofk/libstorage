--
-- FIFO. Part of libstorage
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
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

library libstorage_1;
use libstorage_1.libstorage_pkg.all;

entity fifo_generic is
  generic (
    DEPTH : positive);
  port (
    clk       : in  std_ulogic;
    rst       : in  std_ulogic;
    rd_en_i   : in  std_ulogic;
    rd_data_o : out std_ulogic_vector;
    full_o    : out std_ulogic;
    wr_en_i   : in  std_ulogic;
    wr_data_i : in  std_ulogic_vector;
    empty_o   : out std_ulogic);

end entity fifo_generic;

architecture rtl of fifo_generic is

  constant ADDR_WIDTH : natural := clog2(DEPTH);
  signal wr_addr : unsigned(ADDR_WIDTH downto 0) := (others => '0');
  signal rd_addr : unsigned(ADDR_WIDTH downto 0) := (others => '0');
  signal full_or_empty  : std_ulogic;
  signal empty_not_full : std_ulogic;
begin
  full_o  <= full_or_empty and not empty_not_full;
  empty_o <= full_or_empty and     empty_not_full;

  empty_not_full <= (wr_addr(ADDR_WIDTH) ?= rd_addr(ADDR_WIDTH));
  full_or_empty  <= (wr_addr(ADDR_WIDTH-1 downto 0) ?= rd_addr(ADDR_WIDTH-1 downto 0));
  
  p_main: process (clk) is
  begin
    if rising_edge(clk) then
      if wr_en_i then
        wr_addr <= wr_addr + 1;
      end if;
      if rd_en_i then
        rd_addr <= rd_addr + 1;
      end if;
      if rst then
        wr_addr <= (others => '0');
        rd_addr <= (others => '0');
      end if;
    end if;
  end process p_main;

  dpram: entity libstorage_1.dpram_generic
    generic map (
      DEPTH => DEPTH)
    port map (
      clk       => clk,
      rd_en_i   => rd_en_i,
      rd_addr_i => rd_addr(ADDR_WIDTH-1 downto 0),
      rd_data_o => rd_data_o,
      wr_en_i   => wr_en_i,
      wr_addr_i => wr_addr(ADDR_WIDTH-1 downto 0),
      wr_data_i => wr_data_i);

end architecture rtl;
