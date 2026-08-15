# Backup Retention Cleanup

Print a dry-run report of which backup files a retention policy
would delete.

## Retention policy
- **Max age: 30 days.** A file strictly older than 30 days is a
  deletion candidate ("older than 30 days" means more than exactly
  `30 * 86400` seconds old, checked against the current time — not
  the calendar day-of-month).
- **Always keep the 3 most-recently-modified files**, no matter how
  old they are (ties in modification time won't occur in the test
  data).

A file is safe to delete only if it's older than 30 days **and** not
one of the 3 most-recently-modified files in the directory.

## Input
`$1` is the path to a directory. Backup files sit directly inside
it — no nested subdirectories to worry about. Only regular files
directly inside `$1` count; if `$1` contains subdirectories, ignore
them and everything inside them.

## Output
Print one line per file that should be deleted:
```
DELETE: <filename>
```
sorted alphabetically by filename. If nothing qualifies for deletion,
print exactly:
```
NOTHING TO DELETE
```

## Constraints
- At most 10,000 files directly inside `$1`.
- Filenames never contain whitespace.

## Example
Directory contents (name — age in days):
```
db-2024-01-01.tar.gz — 40 days old
db-2024-01-08.tar.gz — 33 days old
db-2024-01-15.tar.gz — 26 days old
db-2024-01-22.tar.gz — 19 days old
```
`db-2024-01-08.tar.gz` is 33 days old but is one of the 3 most
recent files, so it's protected.

Output:
```
DELETE: db-2024-01-01.tar.gz
```
