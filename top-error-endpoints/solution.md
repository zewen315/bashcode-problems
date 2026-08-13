# Solution

The line format is fixed but irregular at the front (IP, two dashes,
a bracketed timestamp), so the solution deliberately counts fields
*from the end* of the line instead of trying to parse the messy part
(see `solution.sh` below for the full pipeline).

- Counting from the end of a space-delimited line: the last field
  (`$NF`) is the response size, `$(NF-1)` is the status code,
  `$(NF-2)` is the protocol (`HTTP/1.1"`), and `$(NF-3)` is the
  request path. This is more robust than counting from the front,
  since the exact number of leading fields (IP, dashes, timestamp)
  doesn't need to be hardcoded.
- `$(NF-1) ~ /^5[0-9][0-9]$/` matches any 3-digit status code starting
  with `5` — the regex for "any `5xx`".
- `{print $(NF-3)}` emits just the path for every matching line — one
  line of output per error response, duplicates included on purpose.
- `sort | uniq -c` groups identical paths together and counts them —
  `uniq -c` only works on *adjacent* duplicate lines, which is exactly
  why the plain `sort` has to come first.
- `sort -k1,1nr -k2,2` re-sorts `uniq -c`'s `<count> <path>` output by
  count descending, breaking ties on path ascending.
- `head -n 3` keeps only the top 3 — and if fewer than 3 distinct
  paths ever had a `5xx`, `head` naturally just passes through however
  many lines exist, satisfying "print only that many lines" for free.
- The final `awk '{print $1, $2}'` reformats `uniq -c`'s
  count-then-path output (which has a leading space before the count)
  into the clean `<count> <path>` shape the problem asks for.
