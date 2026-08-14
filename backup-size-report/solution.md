# Solution

Find every `*.log` file in the tree, get each one's size, add them
up. Two ways to do the adding.

## 1. `find` + `stat` + `awk`

```bash
find "$1" -name '*.log' -exec stat -c '%s' {} \; | awk '{s+=$1} END{print s+0}'
```

`find ... -exec stat -c '%s' {} \;` turns every matching file into
just its size in bytes, one number per line — `find` recurses into
subdirectories by default, no `-maxdepth` needed. `awk`'s `END{print
s+0}` runs exactly once after all lines are consumed: `s` accumulates
every size (auto-initialized to `0` the first time it's referenced),
and `+0` forces it into numeric context so a completely empty input
(no `.log` files at all) still prints `0` instead of a blank line.

## 2. Bash loop, `wc -c`

```bash
total=0
while IFS= read -r f; do
  size=$(wc -c < "$f")
  total=$((total + size))
done < <(find "$1" -name '*.log')
echo "$total"
```

Same idea without `awk`: `wc -c < "$f"` counts a file's bytes by
reading it through stdin (the `<` redirect, rather than passing the
filename as an argument, is what makes `wc` print just the bare
number with no filename alongside it — `wc -c "$f"` would print
`"123 $f"` instead). `total` starts at `0` explicitly, so the loop
running zero times (no `.log` files) still leaves `0` to print.
