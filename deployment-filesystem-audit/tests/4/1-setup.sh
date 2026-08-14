#!/usr/bin/env bash
cd "$1"
mkdir -p a/b/c
echo 'hello' > a/b/c/notes.log
touch a/b/c/empty_file.dat
ln -s a/b/c/nonexistent a/b/broken
