# Solution

Two things make this trickier than a simple find-and-replace: values
must be substituted *literally* (not as regex patterns — a value
containing `.` or `&` shouldn't be treated specially), and unknown
keys must be left untouched, braces included (see `solution.sh` below
for the full script).

- The script is invoked as `awk '...' "$2" "$1"` — the **variables**
  file first, **template** second — so that when `awk` processes the
  variables file, `ARGIND == 1`, and it's fully loaded into the
  `vars[]` array before any template line is touched.
- `vars[$1] = substr($0, length($1) + 2)` builds the value from the
  *whole* line, not `$2` — `-F=` would otherwise split
  `BALANCE=$100.50` on every `=`, losing anything after the first one.
  Taking everything after the first `=` preserves values that contain
  `=` themselves.
- For each template line (`ARGIND == 2`), `match(line, /\{\{[A-Za-z0-9_]+\}\}/)`
  finds the next `{{KEY}}` placeholder, setting `RSTART`/`RLENGTH` to
  its position and length.
- `key` is the text between the braces; `prefix` is everything before
  the placeholder. If `key` is a known variable, `repl` is its literal
  value; otherwise `repl` is the placeholder text itself (braces
  included), so unknown keys pass through unchanged.
- `result` accumulates `prefix + repl` and `line` is trimmed down to
  whatever comes *after* the placeholder, so the `while` loop finds
  the *next* `{{...}}` on the same line — this is what makes repeated
  placeholders on one line all get replaced, not just the first.
- Because replacement values are inserted via plain string
  concatenation (never handed to a regex or `gsub`), a value like
  `$100.50` is used exactly as written — nothing in it is interpreted
  as a pattern.
