# Solution

Both walk the same two levels of nesting — `.services[]` then, per
service, `.instances[]` — the difference is whether the grouping
back up to "one line per service" happens inside `jq` or after it.

## 1. Pure `jq`

```bash
jq -r '
  .services[]
  | (.instances | map(select(.status != "healthy")) | map(.id)) as $bad
  | select($bad | length > 0)
  | "\(.name): \($bad | join(" "))"
' "$1"
```

For each service, `map(select(.status != "healthy")) | map(.id)`
builds the list of its non-healthy instance ids in one expression,
bound to `$bad` so it's only computed once. `select($bad | length >
0)` is what makes an all-healthy (or empty-`instances`) service
vanish from the output entirely, rather than printing a line with
nothing after the colon. `join(" ")` turns the id array into the
space-separated tail of the line. Because everything stays inside a
single `.services[]` pipeline, service order is whatever order they
appeared in the input — nothing here ever sorts.

## 2. `jq` to flatten, `awk` to group

```bash
jq -r '
  .services[]
  | .name as $s
  | .instances[]
  | select(.status != "healthy")
  | "\($s) \(.id)"
' "$1" | awk '
  {
    if ($1 != prev) {
      if (prev != "") print line
      line = $1 ":"
      prev = $1
    }
    line = line " " $2
  }
  END { if (line != "") print line }
'
```

`jq` here does only the filtering — for every non-healthy instance,
it emits one flat `"service id"` line, with no grouping at all
(`.name as $s` just carries the enclosing service's name down into
the inner `.instances[]` loop). Grouping into `service: id1 id2 ...`
happens in `awk`, the same *adjacent-lines* trick used elsewhere in
this problem set: since `jq` already visits one service's instances
consecutively before moving to the next, a line only needs to be
flushed (`print line`) when `$1` (the service) changes from the
previous row — no sorting or lookahead required. A service that
contributes zero lines to `jq`'s output (fully healthy, or no
instances) never enters this loop at all, so it's automatically
absent from the final output.
