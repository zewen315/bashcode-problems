# Backup Size Report

Given a real directory tree, find out how much space its log files
are actually taking up — the first question before deciding what's
safe to clean up.

## Input
`$1` is the path to a directory, which may contain nested
subdirectories to any depth.

## Task
Find every file named `*.log` anywhere in the tree (recursively), and
print the combined size of all of them, in bytes, as a single integer.

## Output
A single integer: the total size in bytes. If there are no `.log`
files anywhere in the tree, print `0`.

## Constraints
- At most 10,000 files in the directory.
- Non-`.log` files are never counted, regardless of size.
- An empty `.log` file (0 bytes) still counts as a match — it just
  contributes `0` to the total.

## Example
Directory contents (name — size):
```
logs/app.log       — 120 bytes
logs/error.log     — 340 bytes
logs/readme.txt    — 50 bytes   (not a .log file — ignored)
archive/old.log    — 75 bytes
```

Output:
```
535
```
(`120 + 340 + 75`; `readme.txt` doesn't count)
