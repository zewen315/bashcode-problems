#!/usr/bin/env bash
cd "$1"
echo 'backup data' > db-2024-01-01.tar.gz
touch -d '-40 days' db-2024-01-01.tar.gz

echo 'backup data' > db-2024-01-08.tar.gz
touch -d '-33 days' db-2024-01-08.tar.gz

echo 'backup data' > db-2024-01-15.tar.gz
touch -d '-26 days' db-2024-01-15.tar.gz

echo 'backup data' > db-2024-01-22.tar.gz
touch -d '-19 days' db-2024-01-22.tar.gz
