#!/usr/bin/env bash
cd "$1"
mkdir -p sub1 sub2
echo 'shared' > sub1/file1.log
echo 'shared' > sub2/file2.log
echo 'shared' > file3.log
