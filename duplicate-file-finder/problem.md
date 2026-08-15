# Duplicate File Finder

Given a real directory tree, find files with byte-for-byte identical
content, regardless of name or location.

## Input
`$1` is the path to a directory, which may contain nested
subdirectories to any depth.

## Task
Group every regular file by its content. A group only matters if it
has **2 or more** files in it — a file with unique content isn't
reported at all.

## Output
One line per duplicate group:

```
DUPLICATE: <path1> <path2> ... <pathN>
```

Paths are relative to `$1` (no leading `./`), space-separated, sorted
alphabetically within the group. Groups themselves are sorted by
their alphabetically-smallest path. Print nothing if there are no
duplicate groups.

## Constraints
- At most 10,000 files.
- **Empty files are never considered duplicates** — of each other or
  of anything else — even though two empty files are technically
  "identical content." An empty file is always excluded from every
  group.
- Directories and symlinks are never candidates; only regular files.

## Example
Directory contents:
```
a/one.txt      — "hello world"
b/two.txt      — "hello world"
a/three.txt    — "different"
```

`a/one.txt` and `b/two.txt` have identical content. `a/three.txt` is
unique.

Output:
```
DUPLICATE: a/one.txt b/two.txt
```
