# Solution

Three independent checks, run in a fixed order, with two of them
needing the *whole* config file read before they can be answered — so
this is a two-pass `awk` script (config file, then required-keys
file), with the malformed-line check reported immediately and the
other two deferred to `END` (see `solution.sh` below for the full
script).

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
