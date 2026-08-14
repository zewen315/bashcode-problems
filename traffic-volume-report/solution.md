# Solution

This is a filter-compute-sort problem. Two ways to do the filtering
and computing.

## 1. `awk`

`awk` does the filtering and computing in a single pass, leaving
`sort` to handle the ordering.

```bash
awk '$2 * $3 > 50000 { print $1, $2 * $3 }' "$1" | sort -k2,2nr -k1,1
```

- `$2 * $3` computes `requests_per_second × duration_seconds` for
  every line — `awk` treats fields as numbers automatically in an
  arithmetic context, no explicit casting needed.
- The pattern `$2 * $3 > 50000` filters to only the lines whose total
  exceeds the threshold *before* anything is printed, so servers at or
  under 50,000 never appear in the output at all.
- `{ print $1, $2 * $3 }` prints the server name and the same
  computed total (recomputed here since `awk` doesn't remember
  expression results between the pattern and the action).
- `sort -k2,2nr -k1,1` sorts by the second field (the total)
  numerically descending (`nr`), then breaks ties on the first field
  (server name) ascending — exactly the two-level ordering the problem
  asks for, without a second pass over the data.

## 2. Bash loop + `sort`

```bash
while read -r server rps duration; do
  total=$((rps * duration))
  [ "$total" -gt 50000 ] && echo "$server $total"
done < "$1" | sort -k2,2nr -k1,1
```

Same filter-compute-sort shape, just with `read` splitting each line
into named fields and `$(( ))` computing the total instead of `awk`.
Printing `server total` directly (rather than `total server`) works
fine here since `sort -k2` can target the second field regardless of
print order — no need for find-long-running-processes' or top-error-endpoints'
"put the sort key first, then strip it" trick, because nothing here
needs stripping before the final print.
