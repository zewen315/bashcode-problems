# Solution

Filter, then sort — the only wrinkle is that the thing you sort by
(`ELAPSED`) isn't part of the final output, so it needs to travel
through the pipeline and get dropped at the end (see `solution.sh`
below for the full pipeline).

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
