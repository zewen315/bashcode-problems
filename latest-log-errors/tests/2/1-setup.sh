#!/usr/bin/env bash
cd "$1"
echo 'INFO all good' > a.log
touch -d '-1 days' a.log

cat > b.log <<'LOG'
ERROR ignored, not the latest file
LOG
touch -d '-5 days' b.log
