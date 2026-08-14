# Latest Log Errors

A two-step search over a real directory of log files: first find
*which* file to look at, using the filesystem, then find *what's
wrong* in it, using its content.

## Input
`$1` is the path to a directory. It contains a flat mix of files
(some `.log`, some not), each with a real last-modified time.

## Steps
1. Among the `.log` files directly inside `$1` (never look in
   subdirectories), find the single one that was modified most
   recently. If two or more `.log` files are tied for the latest
   mtime, use whichever sorts first alphabetically.
2. Print every line in *that one file* containing the literal text
   `ERROR` (a plain substring match — a line containing
   `NOT_AN_ERRORCODE` counts), in the file's own order.

If there are no `.log` files at all, or the most recent one has no
`ERROR` lines, print nothing.

## Constraints
- At most 10,000 files in the directory.
- At most 10,000 lines in any single file.
- Non-`.log` files are never candidates in step 1, no matter how
  recently they were modified.

## Example
Directory contents (name — last modified):
```
app.log      — 10 days ago
error.log    — 1 day ago   (most recently modified .log file)
debug.log    — 5 days ago
readme.txt   — 1 hour ago  (not a .log file — ignored despite being newest)
```

`error.log`'s content:
```
10:00 INFO starting up
10:05 ERROR connection refused
10:10 INFO retrying
10:12 ERROR timeout
10:15 INFO recovered
```

`readme.txt` is more recent than every `.log` file but never counts.
Among the `.log` files, `error.log` is the most recent, so only its
`ERROR` lines are printed.

Output:
```
10:05 ERROR connection refused
10:12 ERROR timeout
```
