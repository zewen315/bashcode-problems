# Solution

Both approaches filter with the same condition — `jq` is what makes
that condition readable regardless of field order or nesting, unlike
a line-oriented tool that would have to assume a fixed layout.

## 1. Pure `jq`

```bash
jq -s -r '
  map(select((.level == "ERROR" or .level == "CRITICAL") and (.tags | index("prod") != null)))
  | group_by(.service)
  | map({service: .[0].service, count: length})
  | sort_by(.service)
  | sort_by(-.count)
  | .[]
  | "\(.service): \(.count)"
' "$1"
```

`-s` ("slurp") reads every line of input as one big JSON array instead
of processing line-by-line, which `group_by` needs — it operates on a
whole array at once. `.tags | index("prod") != null` is array
membership: `index` returns the position of the first match or `null`
if it's absent, anywhere in the array, regardless of how many other
tags surround it. `group_by(.service)` needs its input already sorted
by that key to group correctly — but since the next step only cares
about each group's *size*, not its order, that's fine; the actual
output order comes later. `sort_by(.service)` then `sort_by(-.count)`
is the standard stable-sort trick for a multi-key sort: `jq`'s
`sort_by` is stable, so sorting by the secondary key (`service`,
ascending) first and the primary key (`count`, descending via
negation) second leaves ties in their already-alphabetical order
without needing a custom comparator.

## 2. `jq` to extract, the shell to aggregate

```bash
jq -r 'select((.level | IN("ERROR", "CRITICAL")) and (.tags | index("prod") != null)) | .service' "$1" \
  | sort \
  | uniq -c \
  | awk '{print $2": "$1}' \
  | sort -t: -k2,2nr -k1,1
```

Here `jq` only decides which lines qualify and prints one bare
`service` name per qualifying line — `IN("ERROR", "CRITICAL")` is
`jq`'s built-in membership check, an alternative to writing out
`== "ERROR" or == "CRITICAL"` by hand. From there it's an ordinary
count-and-sort pipeline: `sort | uniq -c` counts each service's
occurrences (`uniq -c` needs sorted input to group correctly), `awk`
reshapes `uniq -c`'s `"  <count> <service>"` into the required
`"<service>: <count>"`, and the final `sort -t: -k2,2nr -k1,1` sorts
on the two fields around that colon — count (`-k2,2nr`, numeric,
descending) first, service name (`-k1,1`, ascending) as the tie-break.
