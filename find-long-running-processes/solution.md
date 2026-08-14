# Solution

Filter, then sort — the only wrinkle is that the thing you sort by
(`ELAPSED`) isn't part of the final output. Two ways to handle that.

## 1. `awk` + `sort`

```bash
awk 'NR > 1 && $3 > 3600 { print $3, $1, $4 }' "$1" | sort -k1,1nr -k2,2n | awk '{print $2, $3}'
```

- `NR > 1` skips the header line (`awk`'s `NR` is the current line
  number across the whole file, 1-indexed).
- `$3 > 3600` keeps only processes whose `ELAPSED` exceeds one hour in
  seconds.
- The first `awk` prints `ELAPSED PID COMMAND` — elapsed time goes
  *first* here specifically so `sort` can order by it, even though the
  final output doesn't include it.
- `sort -k1,1nr -k2,2n` sorts by the first field (elapsed) numerically
  descending, then breaks ties on the second field (PID) numerically
  ascending — matching "longest-running first, ties by PID ascending."
- The second `awk '{print $2, $3}'` drops the elapsed column, leaving
  just `PID COMMAND` in the required output shape.

This "put the sort key first, sort, then strip it" pattern is common
whenever the field you need to sort by isn't the field you need to
print.

## 2. Bash loop + `sort`

```bash
tail -n +2 "$1" | while read -r pid user elapsed cmd; do
  [ "$elapsed" -gt 3600 ] && echo "$pid $cmd $elapsed"
done | sort -k3,3nr -k1,1n | cut -d' ' -f1,2
```

Same filter-then-sort shape without `awk`: `tail -n +2` drops the
header instead of `NR > 1`, `read` splits each line into named fields
directly instead of `$1`/`$3`/`$4`. This version doesn't need the
"sort key first" trick, though — since `sort -k` can target *any*
field by position regardless of where it sits, `elapsed` can go
*last* (`pid cmd elapsed`, already the shape wanted plus one trailing
field) and `cut -d' ' -f1,2` just drops it at the end.
