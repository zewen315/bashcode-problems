# Solution

Textbook DFS cycle detection: recurse, tracking which nodes are on
the *current* path (not just visited ever), and a back-edge into that
path is the cycle. The only real work is doing it in the exact order
the problem pins down — alphabetical roots, declared-order
dependencies — so two different implementations agree on which cycle
gets reported. Two ways to write the recursion.

## 1. `awk`, a real recursive function

```bash
awk -F': *' '
{
  service = $1
  m = split($2, deps, " ")
  depcount[service] = m
  for (i = 1; i <= m; i++) depnames[service, i] = deps[i]
}
function dfs(node,    i, d, j, cyc) {
  if (found) return
  visited[node] = 1
  path[++pathlen] = node
  inpath[node] = pathlen
  for (i = 1; i <= depcount[node]; i++) {
    d = depnames[node, i]
    if (found) return
    if (inpath[d] > 0) {
      cyc = ""
      for (j = inpath[d]; j <= pathlen; j++) cyc = cyc (cyc == "" ? "" : " -> ") path[j]
      cyc = cyc " -> " d
      print "CYCLE: " cyc
      found = 1
      return
    }
    if (!(d in visited)) dfs(d)
    if (found) return
  }
  inpath[node] = 0
  pathlen--
}
END {
  nroot = asorti(depcount, sortedroots)
  for (k = 1; k <= nroot; k++) {
    if (found) break
    r = sortedroots[k]
    if (!(r in visited)) dfs(r)
  }
}' "$1"
```

The main block just records each service's dependency list, in
order, indexed by position (`depnames[service, i]`) — `awk`'s
equivalent of an array-of-arrays. `dfs()` is the actual search:
`path[]`/`pathlen` is the current path as an explicit stack,
`inpath[node]` is that node's *position* in the stack (not just a
yes/no flag) — which is exactly what makes it possible to slice the
cycle out later: when a dependency `d` is found with `inpath[d] > 0`,
the loop `for (j = inpath[d]; j <= pathlen; j++)` walks from *that*
position to the end of the current path, which is precisely "from
where the loop reopens" rather than from the search root. `found` is
checked and propagated after every recursive call and at the top of
every loop iteration so the *first* cycle discovered stops everything
immediately, no matter how deep the recursion is. `inpath[node] = 0`
and `pathlen--` on the way out are what make "on the current path"
mean the current path — once `dfs` returns from a node, that node
stops counting as an ancestor for sibling branches. `asorti(depcount,
sortedroots)` gets the alphabetical root order for free, since
`depcount`'s keys are exactly the declared services.

## 2. Bash, a recursive function

```bash
declare -A depstr
declare -A visited
declare -A inpath
order=()
path=()
found=0

while IFS=':' read -r service rest; do
  depstr[$service]="$rest"
  order+=("$service")
done < "$1"

dfs() {
  local node="$1"
  [ "$found" -eq 1 ] && return
  visited[$node]=1
  path+=("$node")
  inpath[$node]=${#path[@]}
  local dep
  for dep in ${depstr[$node]}; do
    [ "$found" -eq 1 ] && return
    if [ -n "${inpath[$dep]}" ]; then
      local start=${inpath[$dep]}
      local cyc="" idx
      for ((idx = start - 1; idx < ${#path[@]}; idx++)); do
        cyc+="${cyc:+ -> }${path[$idx]}"
      done
      cyc+=" -> $dep"
      echo "CYCLE: $cyc"
      found=1
      return
    fi
    if [ -z "${visited[$dep]}" ]; then
      dfs "$dep"
      [ "$found" -eq 1 ] && return
    fi
  done
  unset "inpath[$node]"
  path=("${path[@]:0:$((${#path[@]}-1))}")
}

mapfile -t sorted_roots < <(printf '%s\n' "${order[@]}" | sort)
for root in "${sorted_roots[@]}"; do
  [ "$found" -eq 1 ] && break
  if [ -z "${visited[$root]}" ]; then
    dfs "$root"
  fi
done
```

Same algorithm — bash supports genuine recursive functions, and
`local` gives each call its own `node`/`dep`/`start`/`cyc`/`idx`
without a manual stack. `path` is a real array standing in for the
current path; `inpath[$node]=${#path[@]}` records the 1-based
position the same way the `awk` version does, so the cycle-slicing
loop (`for ((idx = start - 1; ...))`) can start exactly where the
back-edge points, just 0-indexed here instead of 1-indexed. Popping a
node on the way out is `path=("${path[@]:0:$((${#path[@]}-1))}")` —
array slicing rather than `unset` on the last index, since `unset` on
an array element leaves a gap in the indices instead of shrinking the
array. `mapfile -t sorted_roots < <(printf '%s\n' "${order[@]}" |
sort)` gets the alphabetical root order the same way `asorti` does,
just via the real `sort` command instead of a `gawk` extension.
