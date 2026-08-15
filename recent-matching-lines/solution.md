# Solution

## 1. `grep` + `tail`

```bash
grep -F -- "$2" "$1" | tail -n "$3"
```

`grep -F` finds every matching line as a literal substring search
(not a regex) and prints just those lines, in their original order
— `tail -n "$3"` then keeps only the last `N` of that filtered
stream. Doing the filtering first and the "last N" second is what
makes this correct: taking the last `N` lines of the *whole file*
and then filtering would answer a different question entirely.
`tail -n 0` (when `$3` is `0`) correctly prints nothing, and `tail
-n` on a stream shorter than `N` just prints everything it got — both
edge cases fall out of `tail`'s own behavior for free.

## 2. `awk`, no `tail`

```bash
awk -v pat="$2" -v n="$3" '
index($0, pat) { matches[++count] = $0 }
END {
  start = (count > n) ? count - n + 1 : 1
  for (i = start; i <= count; i++) print matches[i]
}
' "$1"
```

`index($0, pat)` is `awk`'s substring test — non-zero (truthy) if
`pat` appears anywhere in the line. Every match gets appended to
`matches[]` as the file is read; the "last N" slicing happens once,
at the very end, by computing where to *start* printing from rather
than removing anything. `count - n + 1` only takes over once there
are more matches than `n` — when there aren't, `start` stays `1` and
every match prints. Passing `n = 0` isn't special-cased at all:
`start` becomes `count + 1`, which is always past the end of the
array, so the loop simply doesn't execute.
