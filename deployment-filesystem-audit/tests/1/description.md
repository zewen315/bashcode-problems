A deploy directory:

- `current` — a symlink to `releases/v1`, which doesn't exist (broken)
- `releases/v2/app` — an empty file
- `releases/v2/config.yml` — a normal file with content
- `scripts/rollback.sh` — mode 644 (not executable)
- `scripts/deploy.sh` — mode 755 (executable, fine)
