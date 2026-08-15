#!/usr/bin/env bash
cd "$1"
echo 'backup data' > e-recent.tar.gz
touch -d '-5 days' e-recent.tar.gz

echo 'backup data' > b-recent.tar.gz
touch -d '-10 days' b-recent.tar.gz

echo 'backup data' > d-recent.tar.gz
touch -d '-29 days' d-recent.tar.gz

echo 'backup data' > a-boundary.tar.gz
touch -d '-30 days' a-boundary.tar.gz

echo 'backup data' > c-boundary.tar.gz
touch -d '-31 days' c-boundary.tar.gz
