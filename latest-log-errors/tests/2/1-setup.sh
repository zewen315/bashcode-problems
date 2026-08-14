#!/usr/bin/env bash
cd "$1"
echo 'INFO all good' > api-gateway.11aa22bb.log
touch -d '-1 days' api-gateway.11aa22bb.log

cat > billing-worker.33cc44dd.log <<'LOG'
ERROR ignored, not the latest file
LOG
touch -d '-5 days' billing-worker.33cc44dd.log
