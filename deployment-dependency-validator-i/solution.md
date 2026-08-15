# Solution

Two passes: first learn which services are declared, then check every
dependency against that set. Two ways to do the two passes.

## 1. `awk`, same file twice

```bash
awk -F': *' '
NR == FNR { declared[$1] = 1; next }
{
  service = $1
  n = split($2, deps, " ")
  delete seen
  for (i = 1; i <= n; i++) {
    d = deps[i]
    if (!(d in declared) && !(d in seen)) {
      print "MISSING: " service " depends on undefined service " d
      seen[d] = 1
    }
  }
}' "$1" "$1"
```

`-F': *'` splits each line on a colon plus any following spaces, so
`$1` is the service name and `$2` is its dependency list with no
leading whitespace to worry about. Passing `"$1" "$1"` — the same
filename twice — is the classic `awk` two-pass idiom: `NR == FNR` is
only true while reading the *first* copy (global record count still
matches the per-file record count), so that block just builds the
`declared` set and `next`s past the second block entirely. Once
`awk` starts re-reading the same file as its second argument, `NR !=
FNR` and the real work happens, already in declaration order for
free since that's just the order `awk` reads the file. `seen` resets
per service (`delete seen`) so a dependency listed twice in one
service's line only ever prints once.

## 2. Bash, two explicit passes

```bash
declare -A declared

while IFS=':' read -r service rest; do
  declared[$service]=1
done < "$1"

while IFS=':' read -r service rest; do
  declare -A seen=()
  for dep in $rest; do
    if [ -z "${declared[$dep]}" ] && [ -z "${seen[$dep]}" ]; then
      echo "MISSING: $service depends on undefined service $dep"
      seen[$dep]=1
    fi
  done
done < "$1"
```

Same two-pass shape, written out as two separate `while` loops over
`$1` instead of leaning on `awk`'s `NR == FNR` trick. `IFS=':' read -r
service rest` splits each line at the first colon; that `IFS`
assignment only applies to that one `read`, so the later `for dep in
$rest` (unquoted on purpose) word-splits on the normal whitespace
`IFS`, turning `" auth db"` into the two tokens `auth` and `db` with
the leading space simply disappearing. `seen` is redeclared empty at
the top of every outer iteration, giving each service its own
dedup set the same way `delete seen` does in the `awk` version.
