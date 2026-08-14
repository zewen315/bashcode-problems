# Solution

Read operations line by line, keep a stack of `ADD`ed names, and dump
it on `PRINT`. Three ways to hold the stack:

## 1. Bash array

```bash
history=()
while IFS= read -r line; do
  case "$line" in
    ADD\ *)
      history+=("${line#ADD }")
      ;;
    UNDO)
      [ "${#history[@]}" -gt 0 ] && unset 'history[-1]' && history=("${history[@]}")
      ;;
    PRINT)
      [ "${#history[@]}" -gt 0 ] && printf '%s\n' "${history[@]}"
      ;;
  esac
done < "$1"
```

See `solution.sh`. `unset 'history[-1]'` drops the last element but
leaves a gap in the index, so `history=("${history[@]}")` re-packs it
— skip that and the next `+=` would land past the old length instead
of appending where you'd expect.

## 2. `awk`, array + top pointer

```bash
awk '
  /^ADD / { arr[++top] = substr($0, 5); next }
  /^UNDO$/ { if (top > 0) top--; next }
  /^PRINT$/ { for (i = 1; i <= top; i++) print arr[i] }
' "$1"
```

`top` tracks the stack height directly. `UNDO` never actually deletes
`arr[top]` — it just decrements `top`, so the old value is simply out
of range and gets overwritten by the next `ADD` before anyone reads it.

## 3. Plain string, no arrays

```bash
hist=""
while IFS= read -r line; do
  case "$line" in
    ADD\ *)
      hist="$hist ${line#ADD }"
      ;;
    UNDO)
      hist="${hist% *}"
      ;;
    PRINT)
      for name in $hist; do echo "$name"; done
      ;;
  esac
done < "$1"
```

Keeps the stack as one space-separated string. `${hist% *}` strips the
shortest ` *` suffix — i.e. the last space and everything after it —
which is exactly "pop the last element." Relies on names never
containing whitespace (per the constraints) and on the unquoted `$hist`
in the `for` loop to word-split back into individual names.
