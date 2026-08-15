#!/usr/bin/env bash
cd "$1"
echo 'backup data' > keep1.tar.gz
touch -d '-1 days' keep1.tar.gz

echo 'backup data' > keep2.tar.gz
touch -d '-2 days' keep2.tar.gz

echo 'backup data' > keep3.tar.gz
touch -d '-3 days' keep3.tar.gz

echo 'backup data' > old.tar.gz
touch -d '-40 days' old.tar.gz

mkdir subdir
echo 'should be ignored' > subdir/ancient.tar.gz
touch -d '-500 days' subdir/ancient.tar.gz
