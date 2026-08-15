# Solution

Both approaches do the same three things in order: list top-level
regular files with their mtimes, sort by recency, then split that
ordering into a protected head (the 3 most recent) and a candidate
tail to test against the age cutoff. The only real difference is
whether `awk` or bash arrays do the splitting.

## 1. `find` + `stat` + `awk`

```bash
cd "$1" || exit 1
now=$(date +%s)

candidates=$(find . -mindepth 1 -maxdepth 1 -type f -exec stat -c '%Y %n' {} \; \
  | sort -rn \
  | awk -v now="$now" '
    {
      mtime = $1
      name = $2
      sub(/^\.\//, "", name)
      idx++
      if (idx <= 3) next
      age_days = int((now - mtime) / 86400)
      if (age_days > 30) print name
    }
  ' | sort)

if [ -z "$candidates" ]; then
  echo "NOTHING TO DELETE"
else
  while IFS= read -r name; do
    echo "DELETE: $name"
  done <<< "$candidates"
fi
```

`-mindepth 1 -maxdepth 1 -type f` is what excludes subdirectories
(and their contents) while still catching every top-level regular
file. `stat -c '%Y %n'` prints `<mtime> <name>` per file, and piping
through `sort -rn` orders that numerically by the leading mtime
field, descending — most recent first, which is exactly the order
the recency rule needs. `awk` then just counts: the first 3 rows
(`idx <= 3`) are skipped unconditionally (protected by recency, no
matter their age), and everything after that only prints if its age
in whole days exceeds 30 — `int(...)` truncates rather than rounds,
so a file exactly 30.9 days old is still "30 days old" and kept,
matching "strictly older than 30 days." A final `sort` puts the
survivors in the alphabetical order the output requires, since
mtime order and filename order have no relationship to each other.

## 2. Bash arrays, no `awk`

```bash
cd "$1" || exit 1
now=$(date +%s)

mapfile -t entries < <(find . -mindepth 1 -maxdepth 1 -type f -exec stat -c '%Y %n' {} \; | sort -rn)

result=()
for ((i = 0; i < ${#entries[@]}; i++)); do
  (( i < 3 )) && continue
  mtime="${entries[$i]%% *}"
  name="${entries[$i]#* }"
  name="${name#./}"
  age_days=$(( (now - mtime) / 86400 ))
  (( age_days > 30 )) && result+=("$name")
done

if (( ${#result[@]} == 0 )); then
  echo "NOTHING TO DELETE"
else
  printf '%s\n' "${result[@]}" | sort | while IFS= read -r name; do
    echo "DELETE: $name"
  done
fi
```

Same `find`/`stat`/`sort -rn` setup, but the splitting happens over
an array instead of a stream: `mapfile -t` loads the already-sorted
`mtime name` lines into `entries[]`, and the loop's own index `i`
plays the role `awk`'s `idx` did — `i < 3` skips the protected head,
everything else is a candidate. `${entries[$i]%% *}` /
`${entries[$i]#* }` split each line on its first space using pure
parameter expansion instead of `awk`'s field splitting; bash integer
division in `$(( ))` truncates toward zero the same way `int()`
does, so the boundary behaves identically. The final `printf | sort
| while read` is just formatting the (already-complete) `result`
array — nothing about the *decision* of what belongs in it happens
in that pipeline, only the alphabetical ordering and the `DELETE:`
prefix.
