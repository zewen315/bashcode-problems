#!/usr/bin/env bash
cd "$1"
echo 'backup data' > weekly-08.tar.gz
touch -d '-2 days' weekly-08.tar.gz

echo 'backup data' > weekly-07.tar.gz
touch -d '-8 days' weekly-07.tar.gz

echo 'backup data' > weekly-06.tar.gz
touch -d '-29 days' weekly-06.tar.gz

echo 'backup data' > weekly-05.tar.gz
touch -d '-30 days' weekly-05.tar.gz

echo 'backup data' > weekly-04.tar.gz
touch -d '-31 days' weekly-04.tar.gz

echo 'backup data' > weekly-03.tar.gz
touch -d '-50 days' weekly-03.tar.gz

echo 'backup data' > weekly-02.tar.gz
touch -d '-60 days' weekly-02.tar.gz

echo 'backup data' > weekly-01.tar.gz
touch -d '-70 days' weekly-01.tar.gz

mkdir archive
echo 'should be ignored' > archive/ancient.tar.gz
touch -d '-999 days' archive/ancient.tar.gz
