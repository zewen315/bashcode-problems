# Command History Manager II

A follow-up to [Command History Manager](../command-history-manager):
instead of one undo stack, track the currently deployed version of
each service by name.

## Input
`$1` is the path to a file with one operation per line:

```
SET <service> <version>
GET <service>
DELETE <service>
```

- `SET <service> <version>` records `<version>` as the currently
  deployed version of `<service>`, overwriting any previous value.
- `GET <service>` prints the currently deployed version of
  `<service>`, or `NOT FOUND` if it has no recorded version (never
  set, or already deleted).
- `DELETE <service>` removes `<service>`'s recorded version. If it has
  none, it does nothing.

## Output
The result of every `GET`, in order, one per line.

## Constraints
- At most 100,000 lines.
- `<service>` and `<version>` contain no whitespace.

## Example
Input:
```
SET api v1
SET web v3
GET api
SET api v2
GET api
DELETE web
GET web
```

Output:
```
v1
v2
NOT FOUND
```
