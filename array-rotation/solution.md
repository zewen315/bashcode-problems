# Solution

Read the array from line 1 and `k` from line 2, reduce `k` to
`k mod length` so it never overshoots, then place each element `k`
spots to the right of where it started (wrapping around at the end).
Three ways to do the placement:

## 1. Manual loop, index arithmetic

```bash
read -r -a arr < "$1"
k=$(sed -n '2p' "$1")
n=${#arr[@]}
k=$(( k % n ))
result=()
for ((i = 0; i < n; i++)); do
  src=$(( (i - k + n) % n ))
  result[i]=${arr[$src]}
done
echo "${result[@]}"
```

For each output position `i`, the element that ends up there is
whichever one started `k` spots to its left — `(i - k + n) % n` — with
`+ n` before the `%` so the result stays non-negative even when
`i - k` goes negative (bash's `%` keeps the sign of the dividend).

## 2. Array slicing

```bash
read -r -a arr < "$1"
k=$(sed -n '2p' "$1")
n=${#arr[@]}
k=$(( k % n ))
if (( k == 0 )); then
  echo "${arr[@]}"
else
  echo "${arr[@]: -k} ${arr[@]:0:n-k}"
fi
```

A rotation is really just "swap the last `k` elements and the first
`n - k` elements." `${arr[@]: -k}` slices the last `k` elements
(negative offsets count from the end), `${arr[@]:0:n-k}` slices the
first `n - k`, and printing them in that order does the rotation in
one line. `k == 0` is handled separately because `${arr[@]: -0}` isn't
the same as "no offset" in bash — it's still worth special-casing
rather than relying on that edge behaving how you'd hope.

## 3. `awk`

```bash
awk '
  NR == 1 { n = split($0, arr, " ") }
  NR == 2 {
    k = (n > 0) ? $1 % n : 0
    out = ""
    for (i = 1; i <= n; i++) {
      src = (i - 1 - k + n) % n + 1
      out = out (i > 1 ? " " : "") arr[src]
    }
    print out
  }
' "$1"
```

Same index math as approach 1, just adjusted for `awk`'s 1-indexed
arrays (`split()` fills `arr[1..n]`, so the `-1`/`+1` shift the
0-indexed formula onto that).
