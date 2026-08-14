#!/usr/bin/env bash
cd "$1"
cat > app.log <<'LOG'
09:00 INFO app started
09:30 ERROR should not appear
LOG
touch -d '-10 days' app.log

cat > error.log <<'LOG'
10:00 INFO starting up
10:05 ERROR connection refused
10:10 INFO retrying
10:12 ERROR timeout
10:15 INFO recovered
LOG
touch -d '-1 days' error.log

cat > debug.log <<'LOG'
ERROR should not appear either
LOG
touch -d '-5 days' debug.log

echo 'not a log file' > readme.txt
touch -d '-1 hours' readme.txt
