#!/usr/bin/env bash
cd "$1"
mkdir -p releases/v1 scripts
ln -s releases/v1 current
echo 'ok' > releases/v1/app
cat > scripts/run.sh <<'SH'
#!/bin/sh
echo run
SH
chmod 755 scripts/run.sh
