#!/usr/bin/env bash
cd "$1"
echo 'data' > data.txt
chmod 666 data.txt

mkdir open-dir
chmod 777 open-dir

ln -s data.txt link-to-data
