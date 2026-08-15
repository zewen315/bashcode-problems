# Recent Matching Lines

Print the last N lines that match a pattern — not just the last N
lines overall.

## Input
`$1` is the path to a file. `$2` is a literal substring pattern.
`$3` is `N`.

## Output
Every line containing `$2` as a substring, keeping only the last `N`
of them, printed in their original relative order. If fewer than `N`
lines match, print all of them. If nothing matches, or `N` is `0`,
print nothing.

## Constraints
- At most 100,000 lines.
- `N` is a non-negative integer.

## Example
Input:
```
INFO start
ERROR one
INFO mid
ERROR two
INFO end
ERROR three
```
`$2 = ERROR`, `$3 = 2`.

Output:
```
ERROR two
ERROR three
```
