#!/usr/bin/env bash
cd "$1"
echo 'nothing to see' > notes.txt
touch -d '-1 days' notes.txt
echo 'key: value' > config.yaml
touch -d '-2 days' config.yaml
