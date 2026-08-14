# Solution

Two steps, run in sequence: pick the right file using filesystem
metadata, then search its content. Both approaches share that shape —
they only differ in how step 1 picks the file.

## 1. `find` + `stat` + `sort`

```bash
cd "$1" || exit 1
latest=$(find . -maxdepth 1 -name '*.log' -exec stat -c '%Y %n' {} \; | sort -k1,1nr -k2,2 | head -1 | cut -d' ' -f2-)
[ -n "$latest" ] && grep 'ERROR' "$latest"
```

`find ... -exec stat -c '%Y %n' {} \;` turns every `*.log` file into
one `<mtime> <name>` line. `sort -k1,1nr -k2,2` sorts by mtime
descending first, then by name ascending — so if two files tie for
the latest mtime, the alphabetically-first one sorts to the top
between them. `head -1` takes that top line, `cut -d' ' -f2-` strips
the mtime back off, leaving just the filename. If there were no
`.log` files at all, `latest` comes out empty and the `grep` is
skipped entirely rather than erroring on a blank filename.

## 2. Bash loop + `stat`

```bash
cd "$1" || exit 1
best=""
best_mtime=-1
for f in *.log; do
  [ -e "$f" ] || continue
  mtime=$(stat -c %Y "$f")
  if [ "$mtime" -gt "$best_mtime" ]; then
    best="$f"
    best_mtime="$mtime"
  fi
done
[ -n "$best" ] && grep 'ERROR' "$best"
```

Same idea, tracking the running max by hand instead of a sort. The
tie-break falls out for free here: bash's own filename globbing
already returns matches in alphabetical order, and the comparison is
a *strict* `-gt` — so when a later file ties the current best's
mtime exactly, `best` simply never gets overwritten, leaving whichever
tied file came first alphabetically. `[ -e "$f" ]` guards the case
where no `.log` file matches at all, since an unmatched glob expands
to the literal pattern string `*.log` instead of nothing.
