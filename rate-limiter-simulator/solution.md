# Solution

This is the classic "sliding-window log" rate limiter: per user, keep
the timestamps of their allowed requests, drop the ones that have
aged out of the window, and check the remaining count against the
limit. Two ways to hold that per-user list.

## 1. Bash associative array

```bash
N=2
T=5
declare -A hist

while read -r t user; do
  read -ra arr <<< "${hist[$user]}"
  pruned=()
  for ts in "${arr[@]}"; do
    (( ts > t - T )) && pruned+=("$ts")
  done
  if (( ${#pruned[@]} < N )); then
    pruned+=("$t")
    hist[$user]="${pruned[*]}"
    echo "$t $user ALLOWED"
  else
    hist[$user]="${pruned[*]}"
    echo "$t $user BLOCKED"
  fi
done < "$1"
```

`hist[$user]` stores a user's allowed timestamps as one
space-separated string (bash has no native array-of-arrays, so this
is a real array re-inflated via `read -ra` each line). Every line
first *prunes*: rebuild the list keeping only timestamps still inside
the window `(t - T, t]`. Only after pruning does the count actually
mean "how many of this user's requests are still active" — checking
the count *before* pruning would wrongly count expired requests
against the limit. If the pruned count is under `N`, this request
joins the list and gets `ALLOWED`; otherwise the pruned (but not
appended) list is saved back and it's `BLOCKED` — a blocked request
never occupies a slot.

## 2. `awk`, simulated 2D array

```bash
awk -v N=2 -v T=5 '
{
  t = $1; user = $2
  new_cnt = 0
  for (i = 1; i <= cnt[user]; i++) {
    if (hist[user, i] > t - T) {
      new_cnt++
      tmp[new_cnt] = hist[user, i]
    }
  }
  for (i = 1; i <= new_cnt; i++) hist[user, i] = tmp[i]
  cnt[user] = new_cnt

  if (cnt[user] < N) {
    cnt[user]++
    hist[user, cnt[user]] = t
    print t, user, "ALLOWED"
  } else {
    print t, user, "BLOCKED"
  }
}' "$1"
```

Same algorithm, but `awk` arrays are natively associative and support
a comma-joined subscript (`hist[user, i]`) as a cheap stand-in for a
2D array — `hist[user, 1]`, `hist[user, 2]`, ... are really just
entries in one flat array keyed by the concatenated string `"user" SUBSEP i`.
`cnt[user]` tracks how many of those slots are actually in use. The
prune step rebuilds into a scratch array (`tmp`) first rather than
shrinking `hist` in place, since shifting indices down while also
reading from them in the same loop would be error-prone.
