# Secret Redactor I

Before shipping logs to a third-party aggregator, secrets that got
logged by accident need to be scrubbed. Print every line back out,
with any `key=value` secret masked in place.

## Input
`$1` is the path to a log file. Free-form lines, in any format.

## Task
If `key` (case-insensitive on its letters) is exactly one of
`password`, `secret`, `token`, `api_key`, and it's immediately
followed by `=` and then a value (a run of non-whitespace
characters, up to the next whitespace or end of line), replace the
value with `REDACTED` — the key and `=` stay as written:
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
A line may contain more than one secret. Everything else on a line
is left exactly as it was.

## Output
Print every line of the input, in order, with the redactions above
applied.

## Constraints
- At most 100,000 lines.
- A secret's value is always non-empty.
- A line may contain any number of secrets.

## Example
Input:
```
2024-01-01 10:00:00 INFO user login password=hunter2 status=ok
```

Output:
```
2024-01-01 10:00:00 INFO user login password=REDACTED status=ok
```
