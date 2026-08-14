# Deployment Filesystem Audit

Given a real deploy directory (a full tree, not a single flat folder),
recursively scan it for four kinds of problems.

## Input
`$1` is the path to a directory, which may contain nested
subdirectories to any depth.

## Checks
For every entry anywhere in the tree (recursively):

- `BROKEN_SYMLINK <path>` — a symlink whose target doesn't exist.
- `EMPTY_FILE <path>` — a zero-byte regular file.
- `NOT_EXECUTABLE <path>` — a file named `*.sh` that's missing the
  owner-execute permission bit.
- `WORLD_WRITABLE <path>` — a file or directory (never a symlink —
  see Constraints) with the world-write permission bit set.

A single path can trigger more than one check (e.g. an empty `.sh`
file that's also missing its execute bit) — print one line per
triggered check.

## Output
One line per finding: `<CHECK> <path>`. `<path>` is relative to `$1`
(no leading `./`). Sort by path first; if the same path has more than
one finding, break the tie by check name (alphabetical: `BROKEN_SYMLINK`
< `EMPTY_FILE` < `NOT_EXECUTABLE` < `WORLD_WRITABLE`). Print nothing
if there are no findings.

## Constraints
- At most 10,000 entries (files, directories, and symlinks combined).
- Symlinks are never checked for `WORLD_WRITABLE` — a symlink's own
  permission bits are essentially meaningless (most systems report
  them as wide-open regardless of what they point to), so only regular
  files and directories count.
- No ownership checks (`-user`/`-group`) — not meaningfully testable
  in the judge sandbox, which always runs as one fixed user.

## Example
Directory contents:
```
current -> releases/v1        (broken: releases/v1 doesn't exist)
releases/v2/app                (empty file)
releases/v2/config.yml         (normal file, has content)
scripts/rollback.sh            (mode 644 — not executable)
scripts/deploy.sh              (mode 755 — executable, fine)
```

Output:
```
BROKEN_SYMLINK current
EMPTY_FILE releases/v2/app
NOT_EXECUTABLE scripts/rollback.sh
```
