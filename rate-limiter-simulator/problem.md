# Rate Limiter Simulator

Simulate a sliding-window rate limiter: each user may make at most
**2 requests in any rolling 5-second window**. Decide, request by
request, whether each one is allowed.

## Input
`$1` is the path to a file with one request per line, already sorted
by time:

```
<timestamp> <user>
```

## Rule
For a request at time `t` from user `u`: count how many of `u`'s
**previously allowed** requests have a timestamp strictly greater than
`t - 5`. If that count is less than `2`, the request is `ALLOWED`
(and counts toward future windows); otherwise it's `BLOCKED` (and is
simply discarded — it never counts toward anything).

Users are independent — one user's requests never affect another's.

## Output
Every input line, in order, with the verdict appended:

```
<timestamp> <user> <ALLOWED|BLOCKED>
```

## Constraints
- At most 100,000 requests.
- `timestamp` is a non-negative integer; timestamps never decrease
  from one line to the next.
- `user` contains no whitespace.

## Example
Input:
```
0 alice
1 alice
2 bob
3 alice
4 alice
8 alice
```

Output:
```
0 alice ALLOWED
1 alice ALLOWED
2 bob ALLOWED
3 alice BLOCKED
4 alice BLOCKED
8 alice ALLOWED
```
