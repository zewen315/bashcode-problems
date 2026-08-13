# Solution

This is a filter-compute-sort problem, and `awk` does the filtering
and computing in a single pass, leaving `sort` to handle the ordering
(see `solution.sh` below for the full one-liner).

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
