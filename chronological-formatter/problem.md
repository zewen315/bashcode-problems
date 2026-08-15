# Chronological Formatter

Sort Unix timestamps and format them as human-readable UTC dates.

## Input
`$1` is the path to a file with one Unix timestamp (seconds since
the epoch) per line, in no particular order.

## Output
Every timestamp, formatted as:
```
YYYY-MM-DD HH:MM:SS
```
in UTC, sorted chronologically (earliest first), one per line.

## Constraints
- At most 100,000 timestamps.
- Each timestamp is a non-negative integer.

## Example
Input:
```
1700000000
1690000000
1710000000
```

Output:
```
2023-07-22 04:26:40
2023-11-14 22:13:20
2024-03-09 16:00:00
```
