# Find Invalid Config Lines

Given a server listing, find the lines that don't match the expected
format.

## Input
A single argument: the path to a file. Each line is meant to be:

```
<name> <ip> <port>
```

## Output
Print the line number (starting at `1`) of every line that is
**invalid**, one per line, in ascending order. A line is invalid if:

- It does not have exactly 3 whitespace-separated fields, or
- The third field (`port`) is not made up entirely of digits.

If every line is valid, print nothing.

## Constraints
- The file has at most 100,000 lines.
- Every line is checked, including blank lines — a blank line has
  zero fields and is therefore invalid.

## Example
Input:
```
api-prod-01 10.0.1.10 8080
api-prod-02 10.0.1.11 8080
worker-prod-01 10.0.2.10 9000
invalid-server
db-prod-01 10.0.3.10 5432
cache-prod-01 10.0.4.10 abc
```

Output:
```
4
6
```
