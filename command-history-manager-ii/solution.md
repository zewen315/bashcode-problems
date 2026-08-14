# Solution

Read each line as `<cmd> <service> [version]` and keep a service →
version map. Three ways to hold that map:

## 1. Bash associative array

```bash
declare -A version
while read -r cmd a b; do
  case "$cmd" in
    SET)    version[$a]=$b ;;
    DELETE) unset "version[$a]" ;;
    GET)    echo "${version[$a]:-NOT FOUND}" ;;
  esac
done < "$1"
```

`declare -A` is the direct tool for this: `SET`,
`GET`, and `DELETE` map straight onto assignment, `${arr[key]:-default}`,
and `unset "arr[key]"`. The one gotcha is that `unset` needs its
argument in double quotes, not single — `unset 'version[$a]'` would try
to unset the literal key `$a`, never expanding it.

## 2. `awk`, associative array

```bash
awk '
  $1 == "SET"    { version[$2] = $3; next }
  $1 == "DELETE" { delete version[$2]; next }
  $1 == "GET"    { print ($2 in version) ? version[$2] : "NOT FOUND" }
' "$1"
```

Every `awk` array is associative already, so this is the same idea
with `($2 in version)` standing in for bash's `${arr[key]:-default}`
existence check.

## 3. Parallel indexed arrays, no map at all

```bash
keys=()
values=()
while read -r cmd a b; do
  idx=-1
  for i in "${!keys[@]}"; do
    [ "${keys[$i]}" = "$a" ] && idx=$i && break
  done
  case "$cmd" in
    SET)
      if [ "$idx" -ge 0 ]; then values[$idx]=$b
      else keys+=("$a"); values+=("$b")
      fi
      ;;
    DELETE) [ "$idx" -ge 0 ] && unset 'keys[idx]' 'values[idx]' ;;
    GET)    [ "$idx" -ge 0 ] && echo "${values[$idx]}" || echo "NOT FOUND" ;;
  esac
done < "$1"
```

Worth knowing this exists: macOS ships bash 3.2, which has no
`declare -A` at all — only indexed arrays. This tracks keys and values
in two parallel indexed arrays and does a linear scan for the matching
index on every operation. It works everywhere bash does, at the cost
of O(services seen so far) per operation instead of O(1).
