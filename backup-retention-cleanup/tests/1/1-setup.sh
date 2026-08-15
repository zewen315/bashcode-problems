#!/usr/bin/env bash
cd "$1"
echo 'backup data' > file_e.tar.gz
touch -d '-5 days' file_e.tar.gz

echo 'backup data' > file_a.tar.gz
touch -d '-10 days' file_a.tar.gz

echo 'backup data' > file_d.tar.gz
touch -d '-35 days' file_d.tar.gz

echo 'backup data' > file_c.tar.gz
touch -d '-40 days' file_c.tar.gz

echo 'backup data' > file_b.tar.gz
touch -d '-45 days' file_b.tar.gz

echo 'backup data' > file_f.tar.gz
touch -d '-50 days' file_f.tar.gz
