# Count 404 Errors

Given an access log file, count how many lines contain a `404` HTTP status
code and print just that number.

## Input
A single argument: the path to a log file. Each line looks like:

```
127.0.0.1 - - [10/Aug/2026:12:00:01] "GET /foo HTTP/1.1" 404 512
```

## Output
A single integer — the number of lines whose status code is `404` — printed
to stdout, nothing else.

## Constraints
- The log file has at most 100,000 lines.
- Exactly one status code field per line, space-delimited, always
  surrounded by spaces.
