# Solution

## 1. `cut` + `tr`

```bash
cut -d'|' -f2,4 --output-delimiter=' ' "$1" | tr 'A-Z' 'a-z'
```

`cut -d'|' -f2,4` pulls just the `service` and `status` fields — `cut`
always emits selected fields in their original column order, so
`-f2,4` (already ascending) needs no extra reordering step.
`--output-delimiter=' '` is what turns the two fields into
`service status` instead of `service|status` — without it, `cut`
reuses the *input* delimiter (`|`) between the fields it kept, since
it has no way to know a different separator is wanted for the
output. `tr 'A-Z' 'a-z'` then lowercases the whole line in one pass;
it only touches uppercase Latin letters, so digits, `-`, and `_` in
service names pass through untouched.

## 2. `awk`, one pass

```bash
awk -F'|' '{ print tolower($2 " " $4) }' "$1"
```

`-F'|'` splits every line on the pipe, so `$2` and `$4` are `service`
and `status` directly — no separate extraction step. `tolower()`
applied to the two fields already joined by a literal space does the
same case-folding as `tr`, just inside `awk` instead of a second
pipeline stage.
