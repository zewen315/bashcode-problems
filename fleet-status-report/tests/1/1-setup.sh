#!/usr/bin/env bash
cd "$1"
cat > services.txt <<'EOF'
gateway
auth
db
cache
EOF
echo 'DOWN' > gateway.status
echo 'UP' > auth.status
echo 'UP' > db.status
echo 'UNKNOWN' > cache.status
