# Fleet Status Report

A fleet of services each drop a one-line status file. Given a
manifest of which services to check, look each one up and report
what you find — this is the shape of script that turns "here's a
list of 200 hostnames" into 200 individual lookups, which is exactly
the case `xargs` (with `-I{}` to place each item wherever it's
needed, not just tacked on the end of a command) is built for.

## Input
`$1` is the path to a directory containing:
- `services.txt` — one service name per line: the manifest of which
  services to report on, in the order they should be reported.
- Zero or more `<name>.status` files, each containing exactly one
  line of text (the status — not limited to any fixed set of
  values).

`services.txt` itself is never one of the services being checked.

## Task
For every line in `services.txt`, in order:
- If `<name>.status` exists in `$1`, print `<name>: <contents of
  that file's one line>`.
- If it doesn't exist, print `<name>: MISSING`.

A service name may appear more than once in `services.txt` — treat
each occurrence independently and print a line for each. A
`.status` file that exists but isn't listed in `services.txt` is
never checked and never appears in the output.

## Output
One line per entry in `services.txt`, in manifest order.

## Constraints
- At most 10,000 lines in `services.txt`.
- Service names contain only letters, digits, `-`, and `_` — no
  whitespace.
- `services.txt` has no blank lines.

## Example
Directory contents:
```
services.txt:
  api
  db
  cache

api.status:    UP
db.status:     DOWN
```
(no `cache.status` file)

Output:
```
api: UP
db: DOWN
cache: MISSING
```
