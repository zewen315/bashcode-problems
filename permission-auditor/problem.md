# Permission Auditor

Given a real directory, flag regular files with dangerous
permissions. There's no pre-formatted listing handed to you — inspect
the directory yourself (`ls -l`, `stat`, or anything else) the way
you would on a real box.

## Input
`$1` is the path to a directory. It contains a flat mix of regular
files, and possibly some subdirectories and symlinks too.

## Rules
For every **regular file** directly inside `$1`:
- **`world-writable`**: the "other" write bit is set.
- **`dangerous`**: it's world-writable **and** at least one of the
  three execute bits (owner, group, or other — any of them) is set.
  A file only ever gets one flag — `dangerous` takes priority, never
  print both for the same file.

A file that's neither isn't printed at all. Subdirectories and
symlinks are never evaluated, only skipped — regardless of their own
permission bits.

## Output
One line per flagged file:
```
FLAG: dangerous <filename>
FLAG: world-writable <filename>
```
All `dangerous` lines first, then all `world-writable` lines; each
group sorted alphabetically by filename. `<filename>` is just the
name, not a path. If nothing is flagged, print nothing.

## Constraints
- At most 10,000 entries directly inside `$1`.
- Filenames contain no whitespace.

## Example
Directory contents (name — mode):
```
config.yaml  — 644 (rw-r--r--)
deploy.sh    — 777 (rwxrwxrwx)
secrets.env  — 666 (rw-rw-rw-)
```

Output:
```
FLAG: dangerous deploy.sh
FLAG: world-writable secrets.env
```
