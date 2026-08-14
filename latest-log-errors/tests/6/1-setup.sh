#!/usr/bin/env bash
cd "$1"
echo 'ERROR ancient, irrelevant' > ancient.log
touch -d '-20 days' ancient.log

cat > recent.log <<'LOG'
08:00 INFO boot
08:01 ERROR disk full
08:02 INFO cleanup started
08:03 ERROR disk still full
08:04 INFO cleanup finished
08:05 INFO all clear
LOG
touch -d '-3 days' recent.log

echo 'ERROR mid, irrelevant' > mid.log
touch -d '-9 days' mid.log
