#!/usr/bin/env bash
cd "$1"
cat > services.txt <<'EOF'
api
db
cache
EOF
echo 'UP' > api.status
echo 'DOWN' > db.status
echo 'UNKNOWN' > cache.status
