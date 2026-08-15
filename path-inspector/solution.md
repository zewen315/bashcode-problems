# Solution

## 1. `tr` + `awk` + `paste`

```bash
tr ':' '\n' < "$1" | awk '!seen[$0]++' | paste -sd: -
```

`tr ':' '\n'` turns the one-line `:`-delimited string into one entry
per line — the natural shape for the next two tools, which both
think in terms of lines rather than fields. `!seen[$0]++` is the
standard order-preserving dedup idiom: `seen[$0]++` returns the
value *before* incrementing (`0`, falsy, the first time a line is
seen; `1+`, truthy, every time after), and `!` flips that into "print
only on the first sighting." `paste -sd: -` does the inverse of the
first step — `-s` ("serial") joins every line from stdin back into
one line, `-d:` using `:` as the joiner instead of the default tab.

## 2. `awk`, one pass

```bash
awk -F: '
{
  out = ""
  delete seen
  for (i = 1; i <= NF; i++) {
    if (!seen[$i]++) {
      out = (out == "" ? $i : out ":" $i)
    }
  }
  print out
}' "$1"
```

Same dedup idiom, but everything happens inside a single `awk` pass
instead of a three-stage pipeline: `-F:` splits the line into fields
directly (no `tr` needed to turn it into separate lines first), and
`out` gets built back up manually — the `out == "" ? $i : out ":"
$i` ternary is what avoids a stray leading `:` before the first
field.
