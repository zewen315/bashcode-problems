# Top Error Endpoints

Given an access log file, find the request paths that returned the most
`5xx` (server error) responses.

## Input
A single argument: the path to a log file. Each line looks like:

```
10.0.0.1 - - [10/Aug/2026:10:00:01] "GET /api/users HTTP/1.1" 500 123
```

## Output
The top 3 request paths by number of `5xx` responses, one per line, in
the form:

```
<count> <path>
```

Ordered by count descending; ties broken by path ascending. If fewer than
3 distinct paths have any `5xx` responses, print only that many lines.
Paths with zero `5xx` responses are not printed.

## Constraints
- The log file has at most 100,000 lines.
- Space-delimited fields; from the end of the line the fixed order is
  always: method, path, protocol, status code, response size.
- A `5xx` response is any status code from `500` to `599`.

## Example
Input:
```
10.0.0.1 - - [10/Aug/2026:10:00:01] "GET /api/users HTTP/1.1" 500 123
10.0.0.2 - - [10/Aug/2026:10:00:02] "GET /health HTTP/1.1" 200 12
10.0.0.3 - - [10/Aug/2026:10:00:03] "POST /api/login HTTP/1.1" 503 43
```

Output (abbreviated — a larger log producing these totals):
```
17 /api/login
12 /api/users
4 /api/orders
```
