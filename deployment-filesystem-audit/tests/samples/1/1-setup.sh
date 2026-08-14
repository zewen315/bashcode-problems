#!/usr/bin/env bash
cd "$1"
mkdir -p releases/v2 scripts
ln -s releases/v1 current
touch releases/v2/app
echo 'name: myapp' > releases/v2/config.yml
cat > scripts/rollback.sh <<'SH'
#!/bin/sh
echo rollback
SH
chmod 644 scripts/rollback.sh
cat > scripts/deploy.sh <<'SH'
#!/bin/sh
echo deploy
SH
chmod 755 scripts/deploy.sh
