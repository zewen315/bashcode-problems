# Solution

## 1. `xargs -n`

```bash
xargs -r -n "$2" sh -c 'echo deploy "$@"' _ < "$1"
```

`-n "$2"` is `xargs`'s own batching: it reads all the whitespace-
separated tokens from stdin (one host per line, so one token per
host) and invokes the given command once per group of at most `$2`
of them, preserving input order — exactly the batching this problem
asks for, with no manual grouping logic needed. `sh -c 'echo deploy
"$@"' _` runs once per batch, with that batch's hosts as `$1 $2 ...`
inside the script; `echo deploy "$@"` prints `deploy` followed by
all of them space-separated, which is the exact output line format.
`-r` (`--no-run-if-empty`) is the detail that's easy to miss: without
it, `xargs` still invokes the command *once* even when stdin is
completely empty — a hosts file with zero lines would otherwise print
a single stray `deploy` line instead of nothing.

## 2. Manual batching, no `xargs`

```bash
n="$2"
batch=()
while IFS= read -r host; do
  batch+=("$host")
  if (( ${#batch[@]} == n )); then
    echo "deploy ${batch[*]}"
    batch=()
  fi
done < "$1"
(( ${#batch[@]} > 0 )) && echo "deploy ${batch[*]}"
```

Same grouping, done by hand: `batch` accumulates hosts one at a time,
and gets flushed (printed and reset) the moment it reaches `n`
members. The line after the loop is what handles a final partial
batch — if the loop ends with 1..n-1 hosts still sitting in `batch`
unflushed, that's exactly the "final batch may be smaller" case, and
the `(( ${#batch[@]} > 0 ))` guard is also what makes an empty input
file correctly produce no output at all: the loop body never runs,
`batch` stays empty, and the guard skips the trailing `echo`.
`${batch[*]}` (not `${batch[@]}`) is deliberate — `*` joins the array
into one word using the first character of `IFS`, which is exactly
the single space `deploy <host1> <host2> ...` needs between hosts.
