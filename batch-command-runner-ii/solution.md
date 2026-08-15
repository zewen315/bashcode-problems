# Solution

Both approaches share the same two decisions: keep the command and
its arguments in an **array**, never a string (that's what makes
`"${cmd[@]}" "${batch[@]}"` run the real command with real argument
boundaries, with no `eval` and no risk of `"production cluster"`
getting re-split), and check `$?` immediately after each invocation
so a failing batch can stop the loop before the next one starts.
They differ only in how they walk through the hosts.

## 1. Index slicing

```bash
hosts_file="$1"
n="$2"
shift 2
cmd=("$@")

mapfile -t hosts < "$hosts_file"
total=${#hosts[@]}

i=0
while (( i < total )); do
  batch=("${hosts[@]:i:n}")
  "${cmd[@]}" "${batch[@]}"
  status=$?
  (( status != 0 )) && exit "$status"
  (( i += n ))
done
exit 0
```

`shift 2` drops the hosts-file path and batch size, so `"$@"` is left
holding exactly the command and its existing arguments — capturing
that into the `cmd` array right away is what protects it: every
later reference is `"${cmd[@]}"`, never a re-quoted string. `mapfile
-t` reads the hosts file into an array one line per element (an empty
file produces a zero-length array, which is what makes `total=0`
skip the loop entirely — the "don't run the command at all" case,
for free). `"${hosts[@]:i:n}"` is array-slice syntax, not string
slicing — it copies element*s*, so a batch never touches or reflows
whatever characters happen to be inside a hostname. The moment a
batch's `$?` is nonzero, `exit "$status"` fires immediately, before
`i` even advances — later batches simply never get a chance to run.

## 2. `set --` + `shift`, consuming from the front

```bash
hosts_file="$1"
n="$2"
shift 2
cmd=("$@")

mapfile -t hosts < "$hosts_file"
set -- "${hosts[@]}"

while (( $# > 0 )); do
  take=$(( $# < n ? $# : n ))
  batch=("${@:1:take}")
  shift "$take"
  "${cmd[@]}" "${batch[@]}"
  status=$?
  (( status != 0 )) && exit "$status"
done
exit 0
```

Same idea, but the hosts live in the positional parameters instead
of a separate array: `cmd` is saved off first (since `set --` is
about to overwrite `"$@"` with the hosts list, `cmd` has to already
be safe in its own array before that happens), then `set --
"${hosts[@]}"` loads the hosts into `$1 $2 ...`. `take` caps the
batch at whatever's smaller — `n`, or however many hosts are actually
left (`$#`) — so the final undersized batch falls out naturally
rather than needing a separate check. `shift "$take"` is what
actually consumes them: each iteration's `$#` shrinks by exactly the
batch just taken, so the `while (( $# > 0 ))` condition is both the
loop and the termination check in one.
