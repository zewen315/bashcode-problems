# Solution

Two genuinely different ways to decide "same content": hash every
file and group by hash (fast, one pass), or compare files directly
against each other (no hashing at all, but a pass per pair).

## 1. Hash + group

```bash
cd "$1" || exit 1
find . -mindepth 1 -type f -not -empty -exec md5sum {} \; | sort | awk '
{
  hash = $1
  path = $2
  sub(/^\.\//, "", path)
  if (hash == prevhash) {
    group = group " " path
    count++
  } else {
    if (count >= 2) print "DUPLICATE:" group
    prevhash = hash
    group = " " path
    count = 1
  }
}
END {
  if (count >= 2) print "DUPLICATE:" group
}' | sort -k2,2
```

`-not -empty` drops empty files before they're ever hashed — they
never even reach the grouping step. `md5sum` prints `<hash>  <path>`
per file; piping through `sort` first means every file with the same
hash ends up on *consecutive* lines, which is what makes the
group-by-adjacent-hash trick in `awk` work at all (`hash == prevhash`
only has to compare against the immediately preceding line, not
search back through everything already seen). A group only gets
printed once its boundary is detected — either the next line's hash
differs, or `END` is reached — and only if it collected `2` or more
members. `sort`'s own tiebreak (paths, once hashes match) already
puts each group's members in alphabetical order for free; the final
`sort -k2,2` handles the *other* required order — sorting the
`DUPLICATE:` lines themselves by their first path — since a file's
hash has no relationship to its path.

## 2. Pairwise `cmp`, no hashing

```bash
cd "$1" || exit 1
mapfile -t files < <(find . -mindepth 1 -type f -not -empty | sed 's|^\./||' | sort)

declare -A grouped
result=()

for ((i = 0; i < ${#files[@]}; i++)); do
  [ -n "${grouped[${files[$i]}]}" ] && continue
  group="${files[$i]}"
  for ((j = i + 1; j < ${#files[@]}; j++)); do
    [ -n "${grouped[${files[$j]}]}" ] && continue
    if cmp -s "${files[$i]}" "${files[$j]}"; then
      group="$group ${files[$j]}"
      grouped[${files[$j]}]=1
    fi
  done
  if [ "$(echo "$group" | wc -w)" -ge 2 ]; then
    result+=("DUPLICATE: $group")
  fi
  grouped[${files[$i]}]=1
done

(( ${#result[@]} )) && printf '%s\n' "${result[@]}" | sort -k2,2
exit 0
```

No hash ever gets computed — `cmp -s a b` directly compares two
files' actual bytes and exits `0` if identical, `1` otherwise, so
"same content" is answered exactly, not via a hash's (astronomically
unlikely, but real) chance of collision. Since `files` is already
sorted, the outer loop always starts a new group from the earliest
unclaimed file, and the inner loop only ever looks *forward*, so a
group's members land in alphabetical order without any extra sorting
— the same property approach 1 got from `sort`'s hash-then-path
ordering, arrived at differently. This is `O(n²)` comparisons in the
worst case (every file checked against every other), the real
tradeoff for skipping hashing — perfectly fine at this problem's
scale, but the reason a hash-based approach is what real dedup tools
actually use at scale.

`(( ${#result[@]} )) && printf ...` exists for the same reason it
matters elsewhere in this codebase: `printf '%s\n'` given a *zero*-
element array still runs its format once and prints a blank line
instead of nothing, so this guards the case where there are no
duplicate groups at all.
