# Solution

## 1. `wc` + `grep`

```bash
lines=$(wc -l < "$1")
words=$(wc -w < "$1")
nonblank=$(grep -c . "$1")
echo "$lines $words $nonblank"
```

`wc -l`/`wc -w` are exactly the two counts asked for — piping the
file in with `<` instead of passing it as an argument is what keeps
`wc`'s output to just the bare number (given a filename argument, it
prints the filename after the count too). `grep -c .` counts lines
matching `.` — "any single character" — which is true for every line
except a completely empty one, so it counts non-blank lines
(including whitespace-only ones, since a space is still a character)
without needing a length check written by hand.

## 2. `awk`, one pass

```bash
awk '
{
  lines++
  words += NF
  if (length($0) > 0) nonblank++
}
END { print lines+0, words+0, nonblank+0 }
' "$1"
```

All three counts accumulate together over a single read of the
file instead of three separate passes: `NF` is `awk`'s own
per-line word count, already split on whitespace the same way `wc
-w` counts words; `length($0) > 0` is the direct version of what
`grep -c .` tests indirectly. The `+0` in the `END` block guards an
entirely empty input — an uninitialized `awk` variable reads as `""`
in string context, and concatenating that into `print` would leave a
blank instead of a literal `0`; adding `0` forces numeric context so
all three always print as numbers.
