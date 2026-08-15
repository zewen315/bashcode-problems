# Solution

Same two substitutions either way — one for `key=value` secrets, one
for card-shaped numbers — written in `sed`'s two regex dialects.

## 1. Extended regex (`sed -E`)

```bash
sed -E \
  -e 's/\b(password|secret|token|api_key)=[^[:space:]]+/\1=REDACTED/Ig' \
  -e 's/(^|[^0-9])([0-9]{4}-[0-9]{4}-[0-9]{4}-[0-9]{4}|[0-9]{4} [0-9]{4} [0-9]{4} [0-9]{4}|[0-9]{16})([^0-9]|$)/\1REDACTED_CC\3/g' \
  "$1"
```

**Secrets:** `\b` is a word boundary — it's what makes `\b(password|...)`
fail to match inside `mypassword=` (no boundary between `y` and `p`,
both word characters) while still matching a clean `password=` at
the start of a token. The `I` flag makes the whole match
case-insensitive, but `\1` — the captured key text itself, not the
pattern — is what gets written back, so `Secret=` stays `Secret=`
rather than being normalized to some fixed case. `[^[:space:]]+`
greedily eats the value up to the next whitespace or end of line,
whatever it contains.

**Card numbers:** the three alternatives are the three allowed
shapes (16 bare digits, or 4-4-4-4 split by all-hyphens or
all-spaces). POSIX ERE matching is leftmost-*longest*, not
first-alternative, so at any given position exactly one alternative
can structurally match — a hyphenated number can't accidentally be
read as a run of 16 bare digits, since the hyphens break the count.
The real trick is `(^|[^0-9])` and `([^0-9]|$)` bracketing the whole
alternation: since a plain `[0-9]{16}` has no way to say "and don't
extend further," those two boundary groups are what reject `999...`
runs of 15 or 17 digits — the match can only start and end where a
non-digit (or the edge of the line) already is. `\1` and `\3` put
those boundary characters back unchanged; only the middle group gets
replaced with the literal `REDACTED_CC`.

## 2. Basic regex (plain `sed`)

```bash
sed '
  s/\<\(password\|secret\|token\|api_key\)=[^[:space:]]\+/\1=REDACTED/gI
  s/\(^\|[^0-9]\)\([0-9]\{4\}-[0-9]\{4\}-[0-9]\{4\}-[0-9]\{4\}\|[0-9]\{4\} [0-9]\{4\} [0-9]\{4\} [0-9]\{4\}\|[0-9]\{16\}\)\([^0-9]\|$\)/\1REDACTED_CC\3/g
' "$1"
```

Identical logic, written without `-E`: in BRE, `(`, `)`, `|`, `{`,
`}`, and `+` are literal characters unless escaped, so grouping and
alternation become `\(...\)`, `\|`, and intervals become `\{4\}` —
the reverse of ERE's convention. `\<` is BRE's word-boundary anchor
(a GNU extension, like `\b` in ERE, just spelled differently) and
plays the exact same role rejecting `mypassword=`. Both substitutions
run as separate lines inside one `sed` script rather than two `-e`
flags — `sed` runs every command against every line in order, so the
effect is the same as chaining two separate invocations.
