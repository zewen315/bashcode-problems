# Solution

The permission string is a fixed-width field — every check is just
"is the character at this specific position `w` or `x`?" Two ways to
read positions out of a string.

## 1. `awk`, `substr()`

```bash
awk '
{
  perm = $1
  file = $NF
  if (length(perm) != 10) next
  type = substr(perm, 1, 1)
  if (type != "-") next
  other_w = substr(perm, 9, 1)
  if (other_w != "w") next
  owner_x = substr(perm, 4, 1)
  group_x = substr(perm, 7, 1)
  other_x = substr(perm, 10, 1)
  if (owner_x == "x" || group_x == "x" || other_x == "x") {
    dangerous[file] = 1
  } else {
    worldwritable[file] = 1
  }
}
END {
  n = asorti(dangerous, sorted_d)
  for (i = 1; i <= n; i++) print "FLAG: dangerous " sorted_d[i]
  m = asorti(worldwritable, sorted_w)
  for (i = 1; i <= m; i++) print "FLAG: world-writable " sorted_w[i]
}' "$1"
```

`substr(perm, N, 1)` pulls a single character out at 1-indexed
position `N` — position 9 is the other-write bit, positions 4/7/10
are the three execute bits. `length(perm) != 10` catches both
malformed lines *and* — combined with the very next `type != "-"`
check — filters out directories and symlinks (a directory's leading
`d` still leaves a 10-character string, just with the wrong first
character, which is exactly why the type check is separate from the
length check rather than folded into one condition). Two sets
(`dangerous[file]`, `worldwritable[file]`) rather than one, since a
file needs to land in exactly one group and print in a different
order (`dangerous` entirely before `world-writable`) — `asorti` sorts
each group's filenames alphabetically before printing.

## 2. Bash loop, substring expansion

```bash
declare -A dangerous
declare -A worldwritable

while read -r perm links owner group size file; do
  [ "${#perm}" -eq 10 ] || continue
  [ "${perm:0:1}" = "-" ] || continue
  other_w="${perm:8:1}"
  [ "$other_w" = "w" ] || continue
  owner_x="${perm:3:1}"
  group_x="${perm:6:1}"
  other_x="${perm:9:1}"
  if [ "$owner_x" = "x" ] || [ "$group_x" = "x" ] || [ "$other_x" = "x" ]; then
    dangerous[$file]=1
  else
    worldwritable[$file]=1
  fi
done < "$1"

for f in "${!dangerous[@]}"; do echo "$f"; done | sort | while read -r f; do echo "FLAG: dangerous $f"; done
for f in "${!worldwritable[@]}"; do echo "$f"; done | sort | while read -r f; do echo "FLAG: world-writable $f"; done
```

Same positions, but bash's `${var:offset:length}` is 0-indexed, so
every position shifts down by one from the `awk` version: the
other-write bit is offset `8`, the execute bits are `3`, `6`, and `9`.
`read -r perm links owner group size file` splits each line into the
six named fields directly — no need to reach for `$1`/`$NF`.
Associative-array *keys* have no guaranteed order in bash, which is
why both loops at the end pipe their filenames through `sort` before
printing, instead of relying on iteration order the way `asorti`
does explicitly for `awk`.
