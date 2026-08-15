# Solution

Both approaches boil down to the same regex checked against every
whitespace-split token; the only real difference is which tool does
the splitting and matching.

## The core pattern

Each octet has to reject anything outside `0-255` and reject leading
zeros. Broken into cases:

- `25[0-5]` — 250-255
- `2[0-4][0-9]` — 200-249
- `1[0-9][0-9]` — 100-199
- `[1-9]?[0-9]` — 0-9 or 10-99 (the `?` makes the leading digit
  optional so a bare `0`-`9` still matches, but there's no way to
  get a *second* leading zero out of this branch)

```
(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])
```

repeated four times, joined by literal `\.`, anchored at both ends
(`^...$`) so the match has to consume the *whole* token — the
anchoring is what rejects `10.0.0.5:8080` and `1.2.3.4.5`, since
those aren't wrong digit-wise, they just have extra characters
the anchors don't let through.

## 1. awk

```bash
awk '
{
  n = split($0, tok, /[ \t]+/)
  out = ""
  for (i = 1; i <= n; i++) {
    t = tok[i]
    if (t ~ /^(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])$/) {
      out = (out == "" ? t : out " " t)
    }
  }
  if (out != "") print NR ": " out
}' "$1"
```

`awk` processes one line at a time already, so `NR` *is* the line
number for free. `split($0, tok, /[ \t]+/)` tokenizes on whitespace
into `tok[]`, and each token is tested against the pattern literally
inlined four times — `awk` regexes don't support backreferences or
variable interpolation the way a shell variable would, so writing it
out longhand is simplest. `out` only gets built (and only gets
printed) if at least one token on the line matched, which is what
makes lines with zero matches disappear from the output instead of
printing an empty `N:`.

## 2. bash, per-token `[[ =~ ]]`

```bash
octet='(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])'
ip_re="^${octet}\\.${octet}\\.${octet}\\.${octet}\$"

lineno=0
while IFS= read -r line || [ -n "$line" ]; do
  lineno=$((lineno + 1))
  out=()
  for tok in $line; do
    [[ "$tok" =~ $ip_re ]] && out+=("$tok")
  done
  (( ${#out[@]} )) && printf '%s: %s\n' "$lineno" "${out[*]}"
done < "$1"
exit 0
```

Same pattern, built once into `ip_re` instead of repeated inline —
`[[ =~ ]]` takes the regex from an *unquoted* variable, so it's
worth keeping the octet piece as its own variable rather than
retyping the alternation four times. `for tok in $line` relies on
bash's own word-splitting (deliberately unquoted) to break the line
into tokens the same way `awk`'s `split` does. `|| [ -n "$line" ]`
on the `read` guards a final line with no trailing newline — `read`
still returns non-zero on that last read but `$line` is populated,
so without it the last line would be silently dropped.

The explicit `exit 0` at the end matters here in a way it wouldn't
in a script that ends on an unconditional command: the loop's last
statement is `(( ${#out[@]} )) && printf ...`, and if the *last*
line of input happens to have no matches, that `&&` short-circuits
to a false exit status — which would otherwise become the whole
script's exit code. The grader only compares stdout, but leaving a
script exiting `1` on a perfectly correct run is worth avoiding
regardless.
