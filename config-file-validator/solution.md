# Solution

Three independent checks, run in a fixed order, with two of them
needing the *whole* config file read before they can be answered. Two
ways to run them.

## 1. `awk`

This is a two-pass `awk` script (config file, then required-keys
file), with the malformed-line check reported immediately and the
other two deferred to `END`.

```bash
awk '
  BEGIN { hadError = 0 }
  ARGIND == 1 {
    if ($0 == "") next
    eq = index($0, "=")
    if (eq <= 1) {
      print "Malformed line: " $0
      hadError = 1
      next
    }
    key = substr($0, 1, eq - 1)
    count[key]++
    next
  }
  ARGIND == 2 {
    if ($0 == "") next
    required[$0] = 1
    next
  }
  END {
    ndup = 0
    for (k in count) if (count[k] >= 2) dupKeys[++ndup] = k
    n = asort(dupKeys)
    for (i = 1; i <= n; i++) { print "Duplicate key: " dupKeys[i]; hadError = 1 }

    nmiss = 0
    for (k in required) if (!(k in count)) missKeys[++nmiss] = k
    m = asort(missKeys)
    for (i = 1; i <= m; i++) { print "Missing required key: " missKeys[i]; hadError = 1 }

    if (!hadError) print "VALID"
  }
' "$1" "$2"
```

- `eq = index($0, "=")` finds the first `=` without using `-F=` at
  all — this problem's values are explicitly allowed to contain `=`
  themselves, so splitting on every `=` would corrupt the value. A
  line is malformed when there's no `=` at all (`index` returns `0`)
  or the key would be empty (`eq == 1`, an `=` as the very first
  character) — both are caught by `eq <= 1`.
- Malformed lines are printed **immediately**, in file order, rather
  than being collected — the problem asks for them "in the order they
  appear," which is naturally what a single top-to-bottom pass gives
  you, with no sorting needed.
- Valid `KEY=VALUE` lines increment `count[key]` — this is what
  reveals duplicates *and* doubles as "is this key present at all,"
  reused later for the missing-keys check.
- The required-keys file (`ARGIND == 2`) just records every non-blank
  line into a `required[]` set.
- Both remaining checks wait until `END`, since "is this a duplicate"
  and "is this required key missing" both depend on having seen every
  line of the config file first, not just the current one.
- `asort(dupKeys)` and `asort(missKeys)` (another `gawk` extension,
  sorting an array's *values* this time rather than indices, since
  these arrays are indexed by a counter, not by key) put both lists in
  alphabetical order before printing, matching "sorted alphabetically."
- `hadError` tracks whether *anything* was ever printed across all
  three checks — only if it's still `0` at the very end does the
  script print `VALID`, so a config with only, say, a missing key
  (but no malformed lines or duplicates) still correctly skips `VALID`.

## 2. Classic pipeline (`grep`/`cut`/`sort`/`comm`)

```bash
config="$1"
required="$2"

out=$(
  grep -vE '^[^=]+=|^$' "$config" | sed 's/^/Malformed line: /'
  grep -E '^[^=]+=' "$config" | cut -d= -f1 | sort | uniq -d | sed 's/^/Duplicate key: /'
  comm -23 <(grep -v '^$' "$required" | sort -u) <(grep -E '^[^=]+=' "$config" | cut -d= -f1 | sort -u) | sed 's/^/Missing required key: /'
)

if [ -z "$out" ]; then
  echo VALID
else
  echo "$out"
fi
```

Each check becomes one pipeline instead of one `awk` pass:
`grep -vE '^[^=]+=|^$'` picks out malformed lines directly (matches
`eq <= 1` from approach 1, just as a regex — "doesn't start with a
non-`=` run followed by `=`", also excluding blanks). `cut -d= -f1 |
sort | uniq -d` finds duplicate keys — critically, only over lines
that already passed the malformed check (`grep -E '^[^=]+='` first),
since a keyless malformed line like `=foo` would otherwise `cut` down
to an empty "key" and corrupt the duplicate count. `comm -23` (lines
only in the first of two *sorted* inputs) is a direct way to ask
"which required keys never showed up as a present key." `out`
collects all three, and `VALID` only prints if nothing else did.
