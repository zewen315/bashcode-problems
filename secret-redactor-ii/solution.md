# Solution

## 1. Extended regex (`sed -E`)

```bash
sed -E 's/(^|[^0-9])([0-9]{4}-[0-9]{4}-[0-9]{4}-[0-9]{4}|[0-9]{4} [0-9]{4} [0-9]{4} [0-9]{4}|[0-9]{16})([^0-9]|$)/\1REDACTED_CC\3/g' "$1"
```

The three alternatives are the three allowed shapes (16 bare digits,
or 4-4-4-4 split by all-hyphens or all-spaces). POSIX ERE matching is
leftmost-*longest*, not first-alternative, so at any given position
exactly one alternative can structurally match — a hyphenated number
can't accidentally be read as a run of 16 bare digits, since the
hyphens break the count. The real trick is `(^|[^0-9])` and
`([^0-9]|$)` bracketing the whole alternation: since a plain
`[0-9]{16}` has no way to say "and don't extend further," those two
boundary groups are what reject `999...` runs of 15 or 17 digits —
the match can only start and end where a non-digit (or the edge of
the line) already is. `\1` and `\3` put those boundary characters
back unchanged; only the middle group gets replaced with the literal
`REDACTED_CC`. `g` lets more than one card number get redacted on
the same line.

## 2. Basic regex (plain `sed`)

```bash
sed 's/\(^\|[^0-9]\)\([0-9]\{4\}-[0-9]\{4\}-[0-9]\{4\}-[0-9]\{4\}\|[0-9]\{4\} [0-9]\{4\} [0-9]\{4\} [0-9]\{4\}\|[0-9]\{16\}\)\([^0-9]\|$\)/\1REDACTED_CC\3/g' "$1"
```

Identical logic, written without `-E`: in BRE, `(`, `)`, `|`, and
`{`/`}` are literal characters unless escaped, so grouping and
alternation become `\(...\)` / `\|`, and intervals become `\{4\}` —
the reverse of ERE's convention.
