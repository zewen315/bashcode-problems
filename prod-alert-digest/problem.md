# Prod Alert Digest

Modern services log structured JSON instead of plain text — one
object per line. You can't reliably `grep`/`awk` your way through
that (field order isn't guaranteed, and values can be nested), which
is exactly the gap `jq` fills.

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
- Line 1: `api`, `ERROR`, has `prod` → qualifies.
- Line 2: `staging`, not `prod` → doesn't qualify.
- Line 3: `WARN`, not `ERROR`/`CRITICAL` → doesn't qualify.
- Line 4: `auth`, `CRITICAL`, has `prod` → qualifies.
- Line 5: `auth`, `ERROR`, has `prod` → qualifies.

Output:
```
auth: 2
api: 1
```
