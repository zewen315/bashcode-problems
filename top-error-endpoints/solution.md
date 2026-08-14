# Solution

The line format is fixed but irregular at the front (IP, two dashes,
a bracketed timestamp). Two ways to pull the path and status out of
that.

## 1. `awk`, counting fields from the end

`awk` deliberately counts fields *from the end* of the line instead of
trying to parse the messy part.

```bash
awk '$(NF-1) ~ /^5[0-9][0-9]$/ {print $(NF-3)}' "$1" |
  sort |
  uniq -c |
  sort -k1,1nr -k2,2 |
  head -n 3 |
  awk '{print $1, $2}'
```

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

## 2. `grep -P`, extracting the path directly

```bash
grep -oP '"[A-Z]+ \K[^ ]+(?= HTTP/[0-9.]+" 5[0-9]{2} )' "$1" |
  sort |
  uniq -c |
  sort -k1,1nr -k2,2 |
  head -n 3 |
  sed -E 's/^ +//'
```

Same idea, but instead of splitting the whole line into fields, a
single Perl-compatible regex (`grep -P`) both finds and extracts the
path in one pass: `\K` resets the match start (so only what follows it
is actually output by `-o`), and the trailing `(?= HTTP/[0-9.]+" 5[0-9]{2} )`
is a lookahead that requires a `5xx` status right after the path
*without consuming it* — this is what makes non-`5xx` lines never
match at all, so nothing after this line needs its own filter. The
final `sed -E 's/^ +//'` replaces the trailing `awk` reformat, just
stripping `uniq -c`'s leading spaces instead of reprinting both fields.
