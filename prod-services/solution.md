# Solution

The key observation: every hostname is really just a series of fields
separated by either `-` or `.` — `service`, `environment`, `instance`,
`domain`. Two ways to split on that.

## 1. `awk`

`awk` lets you split on more than one character at once by giving `-F`
a character class instead of a single character.

```bash
awk -F'[.-]' '$2 == "prod" { print $1 }' "$1" | sort -u
```

- `-F'[.-]'` splits each line on *either* `.` or `-`. For
  `api-prod-01.bashcode.net`, that produces fields `api`, `prod`,
  `01`, `bashcode`, `net` — so `$1` is the service name and `$2` is
  the environment, regardless of how many `.`-separated domain labels
  follow.
- `$2 == "prod"` keeps only the lines whose environment field is
  exactly `prod` — a plain string comparison, so `staging` or `PROD`
  correctly don't match.
- `{ print $1 }` prints just the service name for matching lines.
- `sort -u` sorts the output alphabetically and drops duplicates in
  one pass, which is exactly what "unique service names, sorted"
  requires.

No need to validate the hostname shape beyond this — the constraints
guarantee `service` and `environment` never contain `-` or `.`
themselves, so the split is always unambiguous.

## 2. `tr` + `cut` + `grep`

```bash
tr '.' '-' < "$1" | cut -d'-' -f1,2 | grep -- '-prod$' | cut -d'-' -f1 | sort -u
```

`cut` only splits on a single delimiter, so `tr '.' '-'` first
normalizes every `.` to `-`, turning the two-delimiter problem into a
one-delimiter one. `cut -d'-' -f1,2` takes just `service-environment`
off the front of each (now-uniform) line, `grep -- '-prod$'` keeps the
ones ending in `-prod`, and a second `cut -f1` drops the environment,
leaving just the service name.
