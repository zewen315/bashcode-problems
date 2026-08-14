# Solution

The bar is always 20 characters, so the only real work per line is
deciding how many of those 20 characters are `#` versus `-`, then
building the string. Two ways to build it.

## 1. `awk`

```bash
awk '{
  name = $1
  pct = $2
  filled = int(pct * 20 / 100 + 0.5)
  bar = ""
  for (i = 0; i < filled; i++) bar = bar "#"
  for (i = filled; i < 20; i++) bar = bar "-"
  print name, "[" bar "]", pct "%"
}' "$1"
```

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

## 2. Bash + `printf`/`tr`

```bash
while read -r name pct; do
  filled=$(( (pct * 20 + 50) / 100 ))
  bar=$(printf '%*s' "$filled" '' | tr ' ' '#')
  bar+=$(printf '%*s' "$((20 - filled))" '' | tr ' ' '-')
  echo "$name [$bar] ${pct}%"
done < "$1"
```

`(pct * 20 + 50) / 100` is the same "round half up" trick as
approach 1, just rearranged into pure integer arithmetic — bash has no
floats, so `+ 0.5` becomes `+ 50` before the (truncating) integer
division. `printf '%*s' "$filled" ''` pads out `filled` spaces without
a loop (`%*s` takes the width as an argument), and `tr ' ' '#'`
swaps those spaces for `#` — the same trick again for the `-` half,
using the remaining `20 - filled` width.
