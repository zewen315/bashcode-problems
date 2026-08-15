# Backup Retention Cleanup

A real cleanup script never just deletes everything past some age —
it also keeps a safety margin of the most recent backups no matter
how old they've gotten, so a stretch of failed backup jobs can't
wipe out the last good copy. This is the dry-run report a cleanup
script would print before actually deleting anything.

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

The two oldest are both past the 30-day cutoff. The two newest
(`db-2024-01-15...`, `db-2024-01-22...`) are inside the top-3-most-
recent window, so they're protected regardless of age — which means
even `db-2024-01-08...`, which is also within the top 3 most recent
of these 4 files, is protected despite being 33 days old.

Output:
```
DELETE: db-2024-01-01.tar.gz
```
