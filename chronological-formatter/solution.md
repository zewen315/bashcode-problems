# Solution

## 1. Sort the raw numbers, then format

```bash
sort -n "$1" | while read -r t; do
  date -u -d @"$t" +'%Y-%m-%d %H:%M:%S'
done
```

`sort -n` orders the *raw epoch integers* chronologically before any
formatting happens — sorting numbers is unambiguous, so this is the
safer habit regardless of what the final text format looks like.
`date -u -d @"$t"` is what actually converts a timestamp: `-u` forces
UTC (otherwise `date` uses the system's local timezone, which
wouldn't be deterministic for grading), and `@` before the value
tells `date` to interpret it as a Unix timestamp rather than trying
to parse it as a date string. The format string itself, `%Y-%m-%d
%H:%M:%S`, is just the zero-padded pieces in the requested order.

## 2. Format first, then sort the text

```bash
while read -r t; do
  date -u -d @"$t" +'%Y-%m-%d %H:%M:%S'
done < "$1" | sort
```

Same conversion, opposite order: every timestamp gets formatted
first, and a plain `sort` (lexicographic, no `-n`) on the resulting
strings puts them in the right order too. That only works *because*
`%Y-%m-%d %H:%M:%S` is a fixed-width, zero-padded, most-significant-
field-first format — sorting the text ends up identical to sorting
the numbers behind it. That's a property of this specific format,
not something to rely on for timestamps in general (`"3:00 PM"` vs
`"11:00 AM"` would sort wrong as plain text) — approach 1's habit of
sorting the underlying number is the one that generalizes.
