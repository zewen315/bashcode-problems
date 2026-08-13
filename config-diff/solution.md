# Solution

This needs to know, for every key, whether it's in the old file, the
new file, or both — which means loading both files into memory before
printing anything, rather than a single streaming pass (see
`solution.sh` below for the full script).

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
