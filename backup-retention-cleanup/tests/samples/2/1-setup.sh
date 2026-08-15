#!/usr/bin/env bash
cd "$1"
echo 'backup data' > daily-1.tar.gz
touch -d '-1 days' daily-1.tar.gz

echo 'backup data' > daily-2.tar.gz
touch -d '-3 days' daily-2.tar.gz

echo 'backup data' > daily-3.tar.gz
touch -d '-7 days' daily-3.tar.gz

echo 'backup data' > daily-4.tar.gz
touch -d '-15 days' daily-4.tar.gz

echo 'backup data' > daily-5.tar.gz
touch -d '-29 days' daily-5.tar.gz
