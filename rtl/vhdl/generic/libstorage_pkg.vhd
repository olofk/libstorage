--
-- Package file for libstorage
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

package libstorage_pkg is

  function clog2 (
    x : natural)
    return natural;

  function is_pow2 (
    d : integer)
    return boolean;
  
end package libstorage_pkg;

package body libstorage_pkg is

  function clog2 (
    x : natural)
    return natural is
    variable r : real;
    variable l : real;
    variable c : real;
    variable i : integer;
  begin
    if x > 0 then
      return integer(ceil(log2(real(x))));
    else
      return 1;
    end if;
  end function;
  
  function is_pow2 (
    d : integer)
    return boolean is
    variable x : positive := 1;
  begin
    while true loop
      if d = x then
        return true;
      elsif d < x then
        return false;
      else
        x := x*2;
      end if;
    end loop;
    return false;
  end function;

end package body libstorage_pkg;
