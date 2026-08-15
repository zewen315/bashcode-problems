# Solution

```bash
export dir="$1"
xargs -I{} sh -c '
  name="{}"
  if [ -f "$dir/$name.status" ]; then
    printf "%s: %s\n" "$name" "$(cat "$dir/$name.status")"
  else
    printf "%s: MISSING\n" "$name"
  fi
' < "$1/services.txt"
```

`xargs -I{}` runs the given command once per input line, substituting
every literal `{}` in it with that line first — so `name="{}"`
becomes, say, `name="db"` before `sh -c` ever sees the script. That's
what lets the value land in the *middle* of a command (inside a
constructed path) rather than only at the end. `dir` isn't part of
the per-line data, so it's `export`ed once up front — `sh -c`'s
subshell inherits the environment, and doesn't need it threaded
through `{}` or positional args.

A plain `while read` loop over `services.txt` works just as well and
reads a bit more directly — `xargs` isn't required here, just one
reasonable way to write it.
