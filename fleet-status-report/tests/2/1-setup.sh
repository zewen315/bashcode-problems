#!/usr/bin/env bash
cd "$1"
cat > services.txt <<'EOF'
svc-a
svc-b
svc-c
EOF
echo 'UP' > svc-a.status
