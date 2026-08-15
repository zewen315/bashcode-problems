#!/usr/bin/env bash
cd "$1"
echo 'backup data' > only3-a.tar.gz
touch -d '-100 days' only3-a.tar.gz

echo 'backup data' > only3-b.tar.gz
touch -d '-105 days' only3-b.tar.gz

echo 'backup data' > only3-c.tar.gz
touch -d '-110 days' only3-c.tar.gz
