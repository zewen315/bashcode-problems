#!/usr/bin/env bash
cd "$1"
echo 'backup data' > old1.tar.gz
touch -d '-100 days' old1.tar.gz

echo 'backup data' > old2.tar.gz
touch -d '-150 days' old2.tar.gz
