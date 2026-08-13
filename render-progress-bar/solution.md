# Solution

The bar is always 20 characters, so the only real work per line is
deciding how many of those 20 characters are `#` versus `-`, then
building the string (see `solution.sh` below for the full script).

- `filled = int(pct * 20 / 100 + 0.5)` scales the percentage to a
  20-character bar and rounds to the nearest integer. `awk`'s `int()`
  truncates rather than rounds, so adding `0.5` before truncating is
  the standard "round half up" trick — `13 * 20 / 100 = 2.6`, `+ 0.5 =
  3.1`, `int(3.1) = 3`, matching the example in the problem statement.
- The two `for` loops build the bar one character at a time: `#` for
  the first `filled` positions, `-` for the rest, so the total length
  is always exactly 20 regardless of `filled`'s value (including the
  edge cases `filled == 0` and `filled == 20`).
- The final `print` reassembles everything in the required
  `name [bar] percent%` shape, in the same order as the input, since
  `awk` processes lines sequentially and this problem needs no
  sorting or aggregation.
