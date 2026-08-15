#!/usr/bin/env bash
cd "$1"
mkdir -p a b
echo 'hello world' > a/one.txt
echo 'hello world' > b/two.txt
echo 'different' > a/three.txt
