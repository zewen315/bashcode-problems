# Secret Redactor II

Redact card numbers that leaked into a log file. Print every line
back out, with any card-number-shaped number masked in place.

## Input
`$1` is the path to a log file. Free-form lines, in any format.

## Task
A run of exactly 16 digits, in one of these three forms, gets its
*entire* match (separators included) replaced with `REDACTED_CC`:
- 16 digits with no separator: `4111111111111111`
- 4 groups of 4 digits separated by hyphens: `4111-1111-1111-1111`
- 4 groups of 4 digits separated by single spaces: `4111 1111 1111 1111`

The match must not be part of a longer run of digits (immediately
preceded and followed by a non-digit character, or the start/end of
the line) — 15 or 17 digits in a row is not a match, even though it
contains 16 consecutive digits somewhere inside it. Mixing separators
(e.g. `4111-1111 1111-1111`) or wrong group sizes (e.g.
`123-4567-8901-2345`) is also not a match.

Everything else on a line is left exactly as it was.

## Output
Print every line of the input, in order, with the redactions above
applied.

## Constraints
- At most 100,000 lines.
- A line may contain any number of card numbers.

## Example
Input:
```
2024-01-01 10:00:00 INFO user login card=4111-1111-1111-1111 status=ok
```

Output:
```
2024-01-01 10:00:00 INFO user login card=REDACTED_CC status=ok
```
