# Prod Alert Digest

Count qualifying alert events per service from a JSON Lines log.

## Input
`$1` is the path to a file of JSON Lines: one JSON object per line,
each an event with (at least) these fields:
```json
{"service": "api", "level": "ERROR", "tags": ["prod", "us-east"], "message": "..."}
```
- `service`: a string.
- `level`: one of `"INFO"`, `"WARN"`, `"ERROR"`, `"CRITICAL"`.
- `tags`: an array of strings (may be empty).

Extra fields may be present and should be ignored. Field order is
not guaranteed to be the same from line to line.

## Task
An event qualifies if **both**:
- Its `level` is `"ERROR"` or `"CRITICAL"`.
- Its `tags` array contains `"prod"` (anywhere in the array).

Count qualifying events grouped by `service`.

## Output
One line per service that had at least one qualifying event:
```
<service>: <count>
```
Sorted by count descending; services tied on count are sorted
alphabetically. If no event qualifies, print nothing.

## Constraints
- At most 100,000 lines.
- Every line is a single well-formed JSON object with the fields
  described above.

## Example
Input:
```
{"service": "api", "level": "ERROR", "tags": ["prod", "us-east"], "message": "timeout"}
{"tags": ["staging"], "level": "ERROR", "service": "api"}
{"service": "auth", "level": "WARN", "tags": ["prod"]}
{"service": "auth", "level": "CRITICAL", "tags": ["prod", "eu-west"]}
{"level": "ERROR", "tags": ["prod"], "service": "auth"}
```

Output:
```
auth: 2
api: 1
```
