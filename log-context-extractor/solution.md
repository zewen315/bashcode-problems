# Solution

## 1. `grep` already does this

```bash
grep -n -C "$3" -F -- "$2" "$1"
```

`grep -n -C N -F pattern file` *is* this problem, byte for byte —
`-n` prefixes line numbers, `-C N` pulls in `N` lines of context on
each side and prints `-` between a context line's number and its
content vs. `:` for an actual match, merges overlapping/adjacent
windows on its own, and inserts a bare `--` between separate blocks.
`-F` is what makes the pattern a literal substring instead of a
regex — without it, a pattern containing `.` or `*` would mean
something else entirely. `--` (a literal double-dash, not a
`printf`/`echo` thing — see the argument itself) tells `grep` that
what follows is the file/pattern, not a flag, so a pattern that
happens to start with `-` doesn't get parsed as an option. Knowing
this exact flag combination *is* the exercise — it's the same
lookup you'd reach for during a real incident.

## 2. The underlying algorithm, by hand

```bash
n="$3"
mapfile -t lines < "$1"
total=${#lines[@]}

mapfile -t matches < <(grep -n -F -- "$2" "$1" | cut -d: -f1)
(( ${#matches[@]} == 0 )) && exit 0

declare -A is_match
for m in "${matches[@]}"; do is_match[$m]=1; done

starts=()
ends=()
for m in "${matches[@]}"; do
  s=$(( m - n )); (( s < 1 )) && s=1
  e=$(( m + n )); (( e > total )) && e=$total
  if (( ${#starts[@]} > 0 )) && (( s <= ends[-1] + 1 )); then
    ends[-1]=$e
  else
    starts+=("$s")
    ends+=("$e")
  fi
done

for ((b = 0; b < ${#starts[@]}; b++)); do
  (( b > 0 )) && echo "--"
  for ((ln = starts[b]; ln <= ends[b]; ln++)); do
    content="${lines[ln-1]}"
    if [[ -n "${is_match[$ln]}" ]]; then
      echo "${ln}:${content}"
    else
      echo "${ln}-${content}"
    fi
  done
done
```

This is what `-C` is doing internally, spelled out. `grep -n -F` is
still used, but only to find *which* lines match — `cut -d: -f1`
peels off just the line number grep already computed, rather than
re-deriving it. Each match's raw window is clamped at the file's
edges (`s`/`e` bounds), then folded into the running `starts`/`ends`
arrays one match at a time: a new window only starts a new block if
its start comes *after* the current block's end plus one line — `s
<= ends[-1] + 1` is deliberately `+1`, not plain overlap, since two
windows that are merely adjacent (nothing omitted between them)
still need to merge, matching `grep`'s own "don't print a `--` when
nothing was actually skipped" behavior. Once the blocks are final,
printing is direct: `is_match` (built once, up front) decides `:` vs
`-` for a given line number regardless of which block it landed in,
and `--` goes between blocks (`b > 0`), never around them.
