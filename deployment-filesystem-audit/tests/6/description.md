A busier deploy directory mixing several issues across nested paths:

- `current` — a working symlink to `releases/v3`
- `releases/v2/link-to-nowhere` — a broken symlink
- `releases/v3/nested/build.artifact`, `logs/empty.log` — empty files
- `releases/v3/README.md` — normal file with content
- `scripts/start.sh` — mode 755 (executable, fine)
- `scripts/stop.sh` — empty *and* mode 644 (two findings on one path)
- `releases/v3/nested/migrate.sh` — mode 644 (not executable)
- `config/` — mode 777 (world-writable directory)
- `logs/access.log` — mode 666 (world-writable file)
- `scripts/admin-only.sh` — mode 744 (owner *can* execute it, so not
  a `NOT_EXECUTABLE` finding, even though group/other can't)
