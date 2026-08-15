#!/usr/bin/env bash
cd "$1"
cat > services.txt <<'EOF'
queue
EOF
echo 'STARTING' > queue.status
