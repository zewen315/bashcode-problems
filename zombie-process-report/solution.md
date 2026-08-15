# Solution

Three real steps here: build a `pid → cmd` lookup (from *every* line,
not just zombies), group zombies by `ppid` using that lookup, then
sort groups by a two-part key (count descending, `ppid` ascending) —
something neither `awk` nor bash arrays sort natively, so both
approaches lean on the external `sort` command for that part. Two
ways to do the first two steps.

## 1. `awk`, build then `sort`, then reformat

```bash
awk '
  { cmd[$1] = $4 }
  $3 == "Z" { zpid[++zn] = $1; zppid[zn] = $2 }
  END {
    for (i = 1; i <= zn; i++) {
      ppid = zppid[i]
      count[ppid]++
      children[ppid] = children[ppid] (children[ppid] == "" ? "" : ",") zpid[i] ":" cmd[zpid[i]]
    }
    for (p in count) {
      pc = (p in cmd) ? cmd[p] : "UNKNOWN"
      print count[p], p, pc, children[p]
    }
  }
' "$1" | sort -k1,1nr -k2,2n | while read -r count ppid parent_cmd children; do
  echo "PARENT $ppid ($parent_cmd): $count zombies"
  echo "$children" | tr ',' '\n' | sort -t: -k1,1n | while IFS=: read -r pid cmd; do
    echo "  $pid $cmd"
  done
done
```

`cmd[$1] = $4` runs on *every* line unconditionally, building the full
pid→cmd map before anything else happens. The `$3 == "Z"` pattern only
gates which lines get remembered as zombies. In `END`, each zombie's
`ppid` gets a running `count` and its `pid:cmd` appended to a
comma-joined `children` string (`cmd[zpid[i]]` — the zombie's *own*
cmd, already known from the first rule). One line per group —
`count ppid parent_cmd children` — goes to stdout, and `(p in cmd) ?
cmd[p] : "UNKNOWN"` is the whole "does this ppid exist as a pid"
check. `sort -k1,1nr -k2,2n` does the actual two-key sort declaratively
(count descending, ppid ascending) — something that would be real
work to write inside `awk` itself. The final loop reads each sorted
group line back in, prints the `PARENT` header, then splits
`children` on commas and re-sorts *that* by pid (`sort -t: -k1,1n`)
before printing each indented child line.

## 2. Bash associative arrays, same `sort` handoff

```bash
declare -A cmd
declare -A count
declare -A children
zpids=()
zppids=()

while read -r pid ppid state c; do
  cmd[$pid]="$c"
  if [ "$state" = "Z" ]; then
    zpids+=("$pid")
    zppids+=("$ppid")
  fi
done < "$1"

for i in "${!zpids[@]}"; do
  pid="${zpids[$i]}"
  ppid="${zppids[$i]}"
  count[$ppid]=$(( ${count[$ppid]:-0} + 1 ))
  children[$ppid]+="${pid}:${cmd[$pid]},"
done

for ppid in "${!count[@]}"; do
  pc="${cmd[$ppid]:-UNKNOWN}"
  echo "${count[$ppid]} $ppid $pc ${children[$ppid]}"
done | sort -k1,1nr -k2,2n | while read -r cnt ppid pc kids; do
  echo "PARENT $ppid ($pc): $cnt zombies"
  echo "${kids%,}" | tr ',' '\n' | sort -t: -k1,1n | while IFS=: read -r pid c; do
    echo "  $pid $c"
  done
done
```

Same shape, real arrays instead of `awk`'s. `cmd[$pid]="$c"` builds the
lookup on every line; zombies are collected into two parallel index
arrays (`zpids`/`zppids`, since bash has no array-of-structs) rather
than filtered inline. `${cmd[$ppid]:-UNKNOWN}` is bash's own "does
this key exist" shorthand — it substitutes `UNKNOWN` whenever
`cmd[$ppid]` is unset, exactly like `(p in cmd) ? cmd[p] : "UNKNOWN"`
does in `awk`. `${kids%,}` trims the one trailing comma left over from
always appending `,` after each child. Handing the actual two-key sort
off to the real `sort` command is identical to approach 1 — bash
arrays have no ordering guarantees to begin with, so there was never a
"native" sort to reach for here either.
