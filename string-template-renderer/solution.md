# Solution

Two things make this trickier than a simple find-and-replace: values
must be substituted *literally* (not as regex patterns — a value
containing `.` or `&` shouldn't be treated specially), and unknown
keys must be left untouched, braces included. Two ways to handle that.

## 1. `awk`

```bash
# $1: template, $2: variables — passed to awk in the opposite order so
# the variables file (which must be fully loaded first) is ARGIND==1.
awk -F= '
  ARGIND == 1 { vars[$1] = substr($0, length($1) + 2); next }
  ARGIND == 2 {
    line = $0
    result = ""
    while (match(line, /\{\{[A-Za-z0-9_]+\}\}/)) {
      key = substr(line, RSTART + 2, RLENGTH - 4)
      prefix = substr(line, 1, RSTART - 1)
      repl = (key in vars) ? vars[key] : substr(line, RSTART, RLENGTH)
      result = result prefix repl
      line = substr(line, RSTART + RLENGTH)
    }
    print result line
  }
' "$2" "$1"
```

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

## 2. `sed`, with escaping

```bash
template="$1"
vars="$2"
content=$(cat "$template")
while IFS='=' read -r key value; do
  [ -z "$key" ] && continue
  esc_value=$(printf '%s' "$value" | sed -e 's/\\/\\\\/g' -e 's/[&/]/\\&/g')
  content=$(printf '%s\n' "$content" | sed "s/{{${key}}}/${esc_value}/g")
done < "$vars"
printf '%s\n' "$content"
```

`sed`'s substitution *is* regex-based (unlike approach 1's plain string
concatenation), so plugging a raw value straight into `s/.../VALUE/g`
would be wrong the moment `VALUE` contains a character `sed`'s
replacement text treats specially — `&` (whole match) or the delimiter
itself (`/`). `esc_value` backslash-escapes those (backslash first, so
the escaping pass doesn't re-escape its own output) before the value
ever reaches `sed`. Unknown keys are handled implicitly: since the
loop only ever runs a substitution for keys that actually appear in
the variables file, a `{{typo}}` in the template just never matches
any of the `s///` commands and passes through untouched.
