# Solution

Both approaches read the same two bits — "other" write, and any
execute bit — just from different sources: `stat`'s numeric mode, or
`ls -l`'s permission string.

## 1. `stat`, arithmetic on the octal mode

```bash
cd "$1" || exit 1
dangerous=()
worldwritable=()

for f in *; do
  [ -e "$f" ] || continue
  [ -L "$f" ] && continue
  [ -f "$f" ] || continue
  mode=$(stat -c '%a' "$f")
  other=$((mode % 10))
  group=$(((mode / 10) % 10))
  owner=$(((mode / 100) % 10))
  other_write=$(( (other / 2) % 2 ))
  any_exec=$(( (owner % 2) + (group % 2) + (other % 2) ))
  if (( other_write )); then
    if (( any_exec > 0 )); then
      dangerous+=("$f")
    else
      worldwritable+=("$f")
    fi
  fi
done

(( ${#dangerous[@]} )) && printf '%s\n' "${dangerous[@]}" | sort | sed 's/^/FLAG: dangerous /'
(( ${#worldwritable[@]} )) && printf '%s\n' "${worldwritable[@]}" | sort | sed 's/^/FLAG: world-writable /'
exit 0
```

`stat -c '%a'` prints a file's mode as an octal number like `706` —
each digit is independently `owner`/`group`/`other`, and each digit's
bits are `4`=read, `2`=write, `1`=execute. Extracting a digit is just
`% 10`/`/ 10` arithmetic; extracting a *bit* from a digit is the same
trick one level down (`(digit / 2) % 2` isolates the write bit,
`digit % 2` the execute bit). `[ -L "$f" ]` has to run *before* `[ -f
"$f" ]` — `-f` follows symlinks, so a symlink pointing at a regular
file would otherwise pass it and get evaluated by the wrong file's
permissions entirely; checking `-L` first and `continue`-ing rules
that out before `-f` ever gets a chance to be misleading. A plain
`for f in *` never lists dotfiles or matches subdirectory contents,
so nothing here recurses past the top level.

## 2. `ls -l`, parsing the permission string

```bash
dangerous=()
worldwritable=()

while read -r perm _ _ _ _ _ _ _ name; do
  [[ "$perm" == d* || "$perm" == l* ]] && continue
  other_w="${perm:8:1}"
  [ "$other_w" = "w" ] || continue
  owner_x="${perm:3:1}"
  group_x="${perm:6:1}"
  other_x="${perm:9:1}"
  if [ "$owner_x" = "x" ] || [ "$group_x" = "x" ] || [ "$other_x" = "x" ]; then
    dangerous+=("$name")
  else
    worldwritable+=("$name")
  fi
done < <(ls -l "$1" | tail -n +2)

(( ${#dangerous[@]} )) && printf '%s\n' "${dangerous[@]}" | sort | sed 's/^/FLAG: dangerous /'
(( ${#worldwritable[@]} )) && printf '%s\n' "${worldwritable[@]}" | sort | sed 's/^/FLAG: world-writable /'
exit 0
```

`ls -l`'s first line of output is always a `total N` summary, not an
entry — `tail -n +2` drops it. The real trap here is field count:
`ls -l`'s date column is three separate space-separated tokens
(month, day, time), not one, so a line is nine fields before the
filename starts (`perm links owner group size month day time
<name>`), not six — `read`'s own field-splitting only works if every
placeholder before `name` is accounted for; getting that count wrong
silently shifts the date into `name` instead. Checking `perm`'s first
character for `d`/`l` skips directories and symlinks the same way as
approach 1, just from the type character `ls` already prints instead
of a separate `-L` test — for a symlink, `ls -l` also appends `->
target` after the name, but that never matters here since symlink
lines are skipped before `$name` is ever used.
