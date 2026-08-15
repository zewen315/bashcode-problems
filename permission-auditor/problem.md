# Permission Auditor

Given an `ls -l`-style directory listing, flag entries with dangerous
permissions.

## Input
`$1` is the path to a file with one entry per line:

```
<permissions> <links> <owner> <group> <size> <filename>
```

`<permissions>` is a 10-character string like `-rwxr-xr-x`:
position 1 is the entry type (`-` for a regular file, `d` for a
directory, `l` for a symlink), positions 2–4 are the owner's `rwx`,
5–7 the group's, 8–10 everyone else's — each position is either the
letter or `-`.

## Rules
For every entry whose type is `-` (a regular file):
- **`world-writable`**: the "other" write bit (position 9) is `w`.
- **`dangerous`**: it's world-writable **and** at least one of the
  three execute bits (position 4, 7, or 10) is `x`. A file only ever
  gets one flag — `dangerous` takes priority, never print both for
  the same file.

Entries that are neither world-writable nor dangerous aren't printed
at all.

## Skipped entirely
- Directories (type `d`) and symlinks (type `l`) — a symlink's own
  permission bits aren't meaningful (most systems report them as
  wide open regardless of what they point to), so they're never
  evaluated, only skipped.
- Any line whose permission field isn't exactly the expected
  10-character shape starting with one of `-`, `d`, or `l` — skip it,
  don't crash.

## Output
One line per flagged file:

```
FLAG: dangerous <filename>
FLAG: world-writable <filename>
```

All `dangerous` lines first, then all `world-writable` lines; each
group sorted alphabetically by filename within itself.

## Constraints
- At most 100,000 entries.
- `filename` contains no whitespace.
- Permission characters are only `r`, `w`, `x`, or `-` — no
  setuid/setgid/sticky-bit letters (`s`/`S`/`t`/`T`) ever appear.

## Example
Input:
```
-rw-r--r-- 1 alice staff 1024 config.yaml
-rwxrwxrwx 1 alice staff 2048 deploy.sh
-rw-rw-rw- 1 alice staff  512 secrets.env
```

`config.yaml` isn't world-writable (`r--` for other) — not flagged.
`deploy.sh` is world-writable *and* executable — `dangerous`.
`secrets.env` is world-writable but not executable anywhere —
`world-writable`.

Output:
```
FLAG: dangerous deploy.sh
FLAG: world-writable secrets.env
```
