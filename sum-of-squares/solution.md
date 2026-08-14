# Solution

Read `n` from the input file, then compute `1^2 + 2^2 + ... + n^2`.
Three ways to get there:

## 1. `while` loop

```bash
n=$(<"$1")
i=1
sum=0
while [ "$i" -le "$n" ]; do
  sum=$((sum + i * i))
  i=$((i + 1))
done
echo "$sum"
```

Counts `i` up from `1` to `n`, adding `i * i` to `sum` each pass.
Bash's `$(( ))` handles the arithmetic and comparison directly, no
external tools needed.

## 2. `for` loop

```bash
n=$(<"$1")
sum=0
for ((i = 1; i <= n; i++)); do
  sum=$((sum + i * i))
done
echo "$sum"
```

Same accumulation, just written with a C-style `for` instead of manually
incrementing `i` — purely a style choice, not a performance one.

## 3. `awk`, closed-form

```bash
awk '{ n = $1; print n * (n + 1) * (2 * n + 1) / 6 }' "$1"
```

Skips the loop entirely via the identity
`1^2 + ... + n^2 = n(n+1)(2n+1)/6` — the product is always divisible
by 6, so the division is exact, including at `n = 0`.
