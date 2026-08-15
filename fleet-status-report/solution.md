# Solution

Both approaches turn each line of `services.txt` into its own
`.status` lookup via `xargs` — the difference is which of `xargs`'s
two ways to inject the per-line value into the command they use.

## 1. `-I{}`, string interpolation

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

`-I{}` tells `xargs` to run the given command once per input line,
substituting every literal `{}` in it with that line first — so
`name="{}"` becomes, say, `name="db"` before `sh -c` ever sees the
script. That's what lets the value land in the *middle* of a
command (inside a constructed path) rather than only at the end,
which is the whole reason to reach for `xargs -I` instead of just
piping into a command that takes trailing arguments. `dir` isn't
part of the per-line data, so it's `export`ed once up front —
`sh -c`'s subshell inherits the environment, and doesn't need it
threaded through `{}` or positional args.

## 2. `-n1`, positional arguments

```bash
xargs -n1 bash -c '
  dir="$1"
  name="$2"
  if [ -f "$dir/$name.status" ]; then
    printf "%s: %s\n" "$name" "$(cat "$dir/$name.status")"
  else
    printf "%s: MISSING\n" "$name"
  fi
' _ "$1" < "$1/services.txt"
```

`-n1` caps each invocation at one input item, so `xargs` calls
`bash -c '...' _ "$1" <line>` once per line — the trailing `<line>`
lands as an actual argument rather than getting spliced into the
command text. `_` fills the `bash -c`'s `$0` slot (conventionally a
throwaway value, since `$0` is only ever used for error messages),
`"$1"` (the directory, a fixed part of the command template) becomes
the script's `$1`, and the line `xargs` appends becomes `$2`. This
is the safer of the two patterns in general — nothing about the
data ever gets interpolated into a shell command string, so a value
containing a shell metacharacter can't do anything unexpected — even
though it isn't load-bearing here, since service names are
constrained to `[A-Za-z0-9_-]`.
