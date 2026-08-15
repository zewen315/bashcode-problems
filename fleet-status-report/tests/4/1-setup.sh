#!/usr/bin/env bash
cd "$1"
cat > services.txt <<'EOF'
web
EOF
echo 'UP' > web.status
echo 'DOWN' > unused.status
