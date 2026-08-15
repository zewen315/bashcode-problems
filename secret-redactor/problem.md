# Secret Redactor

Before shipping logs to a third-party aggregator, secrets and card
numbers that got logged by accident need to be scrubbed. Print every
line back out, with two categories of sensitive data masked in place.

## Input
`$1` is the path to a log file. Free-form lines, in any format.

## What to redact

**1. `key=value` secrets.** If `key` (case-insensitive on its
letters) is exactly one of `password`, `secret`, `token`, `api_key`,
and it's immediately followed by `=` and then a value (a run of
non-whitespace characters, up to the next whitespace or end of
line), replace the value with `REDACTED` — the key and `=` stay as
written:
```
password=hunter2       ->  password=REDACTED
TOKEN=eyJhbGciOi        ->  TOKEN=REDACTED
```
The key must be a standalone word — if it's the tail end of a longer
identifier, it does not count and nothing is redacted:
```
mypassword=nope        ->  mypassword=nope      (unchanged)
apitoken=notasecret    ->  apitoken=notasecret  (unchanged)
```

**2. Card-number-shaped numbers.** A run of exactly 16 digits, in
one of these three forms, replace the *entire* matched number
(separators included) with `REDACTED_CC`:
- 16 digits with no separator: `4111111111111111`
- 4 groups of 4 digits separated by hyphens: `4111-1111-1111-1111`
- 4 groups of 4 digits separated by single spaces: `4111 1111 1111 1111`

The match must not be part of a longer run of digits (immediately
preceded and followed by a non-digit character, or start/end of
line) — 15 or 17 digits in a row is not a match, even though it
contains 16 consecutive digits somewhere inside it. Mixing separators
(e.g. `4111-1111 1111-1111`) or wrong group sizes (e.g.
`123-4567-8901-2345`) is also not a match.

Everything else on a line is left exactly as it was.

## Output
Print every line of the input, in order, with the redactions above
applied.

## Constraints
- At most 100,000 lines.
- A secret's value is always non-empty.
- A line may contain any number of secrets and card numbers, in any
  combination.

## Example
Input:
```
2024-01-01 10:00:00 INFO user login password=hunter2 card=4111-1111-1111-1111 status=ok
```

Output:
```
2024-01-01 10:00:00 INFO user login password=REDACTED card=REDACTED_CC status=ok
```
