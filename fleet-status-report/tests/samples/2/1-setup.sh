#!/usr/bin/env bash
cd "$1"
cat > services.txt <<'EOF'
web
worker
EOF
echo 'UP' > web.status
