#!/usr/bin/env bash
cd "$1"
echo 'ERROR ancient, irrelevant' > notify-worker.abc12345.log
touch -d '-20 days' notify-worker.abc12345.log

cat > search-index.def67890.log <<'LOG'
08:00 INFO boot
08:01 ERROR disk full
08:02 INFO cleanup started
08:03 ERROR disk still full
08:04 INFO cleanup finished
08:05 INFO all clear
LOG
touch -d '-3 days' search-index.def67890.log

echo 'ERROR mid, irrelevant' > cache-evictor.a1a1a1a1.log
touch -d '-9 days' cache-evictor.a1a1a1a1.log
