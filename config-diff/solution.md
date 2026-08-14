# Solution

This needs to know, for every key, whether it's in the old file, the
new file, or both — which means loading both files into memory before
printing anything, rather than a single streaming pass. Two ways to
hold that.

## 1. `awk`

```bash
awk -F= '
  { eq = index($0, "="); key = substr($0, 1, eq - 1) }
  ARGIND == 1 { old[key] = $0; oldset[key] = 1 }
  ARGIND == 2 { new[key] = $0; newset[key] = 1 }
  END {
    for (k in oldset) all[k] = 1
    for (k in newset) all[k] = 1
    n = asorti(all, sorted)
    for (i = 1; i <= n; i++) {
      k = sorted[i]
      if ((k in oldset) && (k in newset)) {
        if (old[k] != new[k]) {
          print "- " old[k]
          print "+ " new[k]
        }
      } else if (k in oldset) {
        print "- " old[k]
      } else {
        print "+ " new[k]
      }
    }
  }
' "$1" "$2"
```

- `key = substr($0, 1, eq - 1)` extracts the key using `index()`
  rather than relying on `-F=`'s own field split — this matters
  because `-F=` would break on a value containing `=`, but the
  problem's constraints say keys and values never contain `=`, so this
  is really just a defensive habit rather than something the test
  data requires.
- `ARGIND` distinguishes which of the two input files a line came
  from: `1` for the old config, `2` for the new one (`awk` numbers
  `ARGV` entries starting at 1, and `ARGIND` tracks which one is
  currently being read). Each file's full lines and a presence flag
  (`oldset`/`newset`) are stored keyed by their config key.
- Everything happens in `END` because the diff for any given key can
  depend on data from *both* files, which aren't fully loaded until
  both have been read.
- `for (k in oldset) all[k] = 1` followed by the same for `newset`
  builds the union of every key from both files, then `asorti(all,
  sorted)` sorts those keys alphabetically into the `sorted` array —
  `asorti` is a `gawk` extension (this judge runs `gawk`) that sorts
  an array's *indices* rather than its values.
- The final loop walks the sorted keys and prints exactly one of three
  shapes per key: both `-`/`+` lines if the key exists in both configs
  with different values, just `-` if it was removed, just `+` if it
  was added — and nothing at all if the key is unchanged, since that
  case falls through without a matching branch.

## 2. Bash associative arrays

```bash
declare -A old new
while IFS='=' read -r key value; do old[$key]=$value; done < "$1"
while IFS='=' read -r key value; do new[$key]=$value; done < "$2"

{
  (( ${#old[@]} )) && printf '%s\n' "${!old[@]}"
  (( ${#new[@]} )) && printf '%s\n' "${!new[@]}"
} | sort -u | while read -r key; do
  if [[ -v old[$key] && -v new[$key] ]]; then
    if [ "${old[$key]}" != "${new[$key]}" ]; then
      echo "- ${key}=${old[$key]}"
      echo "+ ${key}=${new[$key]}"
    fi
  elif [[ -v old[$key] ]]; then
    echo "- ${key}=${old[$key]}"
  else
    echo "+ ${key}=${new[$key]}"
  fi
done
```

Same idea without `awk`: two associative arrays instead of one `awk`
array with a presence flag, `sort -u` for the key union instead of
`asorti`, and `[[ -v arr[key] ]]` to test presence directly. Worth
knowing: `printf '%s\n' "${!old[@]}"` on a *zero-element* array still
runs the format once and prints a spurious blank line — the `(( ${#old[@]} ))`
guard exists specifically to skip that call when either file is empty.
