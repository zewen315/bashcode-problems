# Solution

Track two things while reading the file: the ordered list of services
`>= 80`, and how many of those are also `>= 90`. Two ways to do it.

## 1. `awk`

```bash
awk '
  $2 >= 80 {
    high = high (high == "" ? "" : " ") $1
    n++
  }
  $2 >= 90 { crit++ }
  END {
    if (n == 0) print "ALL HEALTHY"
    else {
      print "High CPU: " high
      print "Critical: " crit + 0
    }
  }
' "$1"
```

`high` is built up as a single space-separated string as matching
lines are read, rather than an array — `high (high == "" ? "" : " ") $1`
appends a leading space only when `high` already has something in it,
so there's never a stray space at the start. `n` counts how many
services ever hit the first rule, which is what decides `ALL HEALTHY`
vs. the two-line output — not whether `crit` is nonzero, since a
config full of `80`s-but-no-`90`s must still print `Critical: 0`, not
`ALL HEALTHY`. `crit + 0` forces `crit` into numeric context so an
untouched (never-incremented) counter prints as `0` rather than an
empty string.

## 2. Bash loop

```bash
high=()
crit=0
while read -r service usage; do
  if [ "$usage" -ge 80 ]; then
    high+=("$service")
    [ "$usage" -ge 90 ] && crit=$((crit + 1))
  fi
done < "$1"

if [ "${#high[@]}" -eq 0 ]; then
  echo "ALL HEALTHY"
else
  echo "High CPU: ${high[*]}"
  echo "Critical: $crit"
fi
```

Same two rules, just with a real bash array instead of a hand-built
string — `high+=("$service")` appends, `${high[*]}` joins with spaces
for the final line, and `${#high[@]}` being `0` is the direct
"nothing ever qualified" check instead of a separate counter.
