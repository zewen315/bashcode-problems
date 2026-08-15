#!/usr/bin/env bash
cd "$1"
cat > services.txt <<'EOF'
api
api
db
EOF
echo 'UP' > api.status
echo 'DOWN' > db.status
