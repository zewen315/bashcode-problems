# Solution

A simulation, not a lookup: walk the startup order once, and for each
service, check whether everything it needs is already in the
`started` set built up so far. Two ways to hold that set and the
per-service dependency lists.

## 1. `awk`, two files

```bash
awk -F': *' '
NR == FNR {
  service = $1
  n = split($2, deps, " ")
  depcount[service] = n
  for (i = 1; i <= n; i++) depnames[service, i] = deps[i]
  next
}
{
  service = $1
  ok = 1
  missing_n = 0
  for (i = 1; i <= depcount[service]; i++) {
    d = depnames[service, i]
    if (!(d in started)) {
      ok = 0
      missing_n++
      missing[missing_n] = d
    }
  }
  if (ok) {
    started[service] = 1
  } else {
    any_failed = 1
    for (i = 1; i <= missing_n; i++) {
      print "MISSING: " service " depends on " missing[i] ", which never started"
    }
  }
}
END {
  if (!any_failed) print "ALL SERVICES STARTED"
}' "$1" "$2"
```

`NR == FNR` is only true while reading the *first* file (`$1`), so
that block just records each service's declared dependency list, in
order — same two-pass idiom as Part I originally used, just now the
second "pass" is a genuinely different file (`$2`) instead of the
same file read twice. Once `$2` starts, each line is one attempt: walk
`service`'s dependency list checking `d in started` — a dependency
that's late, never scheduled, or itself failed all look identical
here, since none of them ever made it into `started`. A service either
starts clean (added to `started`, available to everything after it)
or fails outright (every unmet dependency printed, `started` untouched
— no partial credit, no second attempt). `any_failed` is what decides
whether `ALL SERVICES STARTED` gets printed at the very end.

## 2. Bash, two files

```bash
declare -A depstr
declare -A started
any_failed=0

while IFS=':' read -r service rest; do
  depstr[$service]="$rest"
done < "$1"

while read -r service; do
  [ -z "$service" ] && continue
  ok=1
  missing=()
  for dep in ${depstr[$service]}; do
    if [ -z "${started[$dep]}" ]; then
      ok=0
      missing+=("$dep")
    fi
  done
  if [ "$ok" -eq 1 ]; then
    started[$service]=1
  else
    any_failed=1
    for dep in "${missing[@]}"; do
      echo "MISSING: $service depends on $dep, which never started"
    done
  fi
done < "$2"

[ "$any_failed" -eq 0 ] && echo "ALL SERVICES STARTED"
```

Same two-file, two-loop shape: the first loop over `$1` just builds
`depstr[service]` (a space-joined dependency list, bash's usual
stand-in for a per-key array). The second loop is the actual
simulation, one line of `$2` per iteration — `${started[$dep]}` being
empty covers all three "not available" cases at once (late, never
scheduled, already failed) the same way `d in started` does in the
`awk` version, since a failed service is simply never added to
`started` in the first place.
