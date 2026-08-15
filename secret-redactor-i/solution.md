# Solution

## 1. Extended regex (`sed -E`)

```bash
sed -E 's/\b(password|secret|token|api_key)=[^[:space:]]+/\1=REDACTED/Ig' "$1"
```

`\b` is a word boundary — it's what makes `\b(password|...)` fail to
match inside `mypassword=` (no boundary between `y` and `p`, both
word characters) while still matching a clean `password=` at the
start of a token. The `I` flag makes the whole match case-insensitive,
but `\1` — the captured key text itself, not the pattern — is what
gets written back, so `Secret=` stays `Secret=` rather than being
normalized to some fixed case. `[^[:space:]]+` greedily eats the
value up to the next whitespace or end of line, whatever it
contains. `g` lets more than one secret get redacted on the same
line.

## 2. Basic regex (plain `sed`)

```bash
sed 's/\<\(password\|secret\|token\|api_key\)=[^[:space:]]\+/\1=REDACTED/gI' "$1"
```

Identical logic, written without `-E`: in BRE, `(`, `)`, `|`, and `+`
are literal characters unless escaped, so grouping and alternation
become `\(...\)` and `\|` — the reverse of ERE's convention. `\<` is
BRE's word-boundary anchor (a GNU extension, like `\b` in ERE, just
spelled differently) and plays the exact same role rejecting
`mypassword=`.
