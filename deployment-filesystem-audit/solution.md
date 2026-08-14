# Solution

Four independent checks over the same tree. Two ways to structure
that: run `find` once per check, or walk the tree once and apply all
four checks to each entry as it's visited.

## 1. One `find` per check

```bash
cd "$1" || exit 1

{
  find . -mindepth 1 -type l | while read -r f; do
    [ -e "$f" ] || echo "BROKEN_SYMLINK ${f#./}"
  done

  find . -mindepth 1 -type f -empty | while read -r f; do
    echo "EMPTY_FILE ${f#./}"
  done

  find . -mindepth 1 -type f -name '*.sh' ! -perm -100 | while read -r f; do
    echo "NOT_EXECUTABLE ${f#./}"
  done

  find . -mindepth 1 \( -type f -o -type d \) -perm -002 | while read -r f; do
    echo "WORLD_WRITABLE ${f#./}"
  done
} | sort -k2,2 -k1,1
```

Each check is its own `find`, piped together and sorted once at the
end. `-mindepth 1` excludes `.` itself (the audit root shouldn't show
up as a finding about itself). `-type l` finds symlinks;
`[ -e "$f" ]` on a symlink follows it, so a false result means the
target doesn't exist — this is the two-step stand-in for GNU find's
`-xtype l`, which isn't available here. `-empty` is a direct BusyBox
predicate. `! -perm -100` negates "owner-execute bit set" for `.sh`
files. `-perm -002` checks the world-write bit — deliberately scoped
to `\( -type f -o -type d \)`, explicitly excluding symlinks, because
a symlink's own permission bits are essentially fictional (most
systems report them as wide-open regardless of the target) and would
otherwise show every symlink as a false-positive `WORLD_WRITABLE`.
Sorting on `sort -k2,2 -k1,1` works because every line is exactly two
whitespace-separated fields (`CHECK path`, and paths never contain
spaces) — field 2 is the path (primary key), field 1 the check name
(tiebreak).

## 2. One pass, one loop

```bash
cd "$1" || exit 1

find . -mindepth 1 | while read -r f; do
  path="${f#./}"
  if [ -L "$f" ]; then
    [ -e "$f" ] || echo "BROKEN_SYMLINK $path"
    continue
  fi
  if [ -f "$f" ] || [ -d "$f" ]; then
    perm=$(stat -c %a "$f")
  fi
  if [ -f "$f" ]; then
    [ -s "$f" ] || echo "EMPTY_FILE $path"
    case "$f" in
      *.sh)
        owner=$(( (8#$perm / 64) % 8 ))
        [ $((owner & 1)) -eq 0 ] && echo "NOT_EXECUTABLE $path"
        ;;
    esac
  fi
  if [ -f "$f" ] || [ -d "$f" ]; then
    other=$((8#$perm % 8))
    [ $((other & 2)) -ne 0 ] && echo "WORLD_WRITABLE $path"
  fi
done | sort -k2,2 -k1,1
```

Same four checks, but the tree is only walked once — a single `find .`
lists every entry, and each one gets branched on by type instead of
re-scanning the whole tree per check. Both permission checks come from
one `stat -c %a` call (the file's mode as an octal string, e.g. `644`):
`(8#$perm / 64) % 8` pulls out the *owner*'s digit and `& 1` tests its
execute bit, `8#$perm % 8` pulls out the *other* digit and `& 2` tests
its write bit — arithmetic doing what `-perm -100` and `-perm -002` do
declaratively in approach 1. This matters more than it looks: a naive
`[ -x "$f" ]` here would be checking *this process's* actual ability
to execute the file — which, since the sandbox never owns anything it
audits, resolves to the file's *other* bit, not its *owner* bit. Those
two normally agree, but not always (a `744` file — owner can execute,
group/other can't — is a real counterexample), which is exactly why
`stat` and manual bit math are used instead of asking `[ -x ]`.
