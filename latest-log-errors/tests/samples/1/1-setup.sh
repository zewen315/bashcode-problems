#!/usr/bin/env bash
cd "$1"
cat > payments.9f3e7a21.log <<'LOG'
09:00 INFO payments started
09:30 ERROR should not appear
LOG
touch -d '-10 days' payments.9f3e7a21.log

cat > auth-service.a1b2c3d4.log <<'LOG'
10:00 INFO starting up
10:05 ERROR connection refused
10:10 INFO retrying
10:12 ERROR timeout
10:15 INFO recovered
LOG
touch -d '-1 days' auth-service.a1b2c3d4.log

cat > worker-queue.5c8d0e12.log <<'LOG'
ERROR should not appear either
LOG
touch -d '-5 days' worker-queue.5c8d0e12.log

echo '# not a log file' > README.md
touch -d '-1 hours' README.md
