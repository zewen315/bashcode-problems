#!/usr/bin/env bash
cd "$1"
cat > services.txt <<'EOF'
zeta
alpha
missing-svc
zeta
beta
EOF
echo 'UP' > zeta.status
echo 'DOWN' > alpha.status
echo 'UNKNOWN' > beta.status
echo 'UP' > extra-unused.status
