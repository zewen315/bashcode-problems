#!/usr/bin/env bash
cd "$1"
mkdir -p scripts
touch scripts/broken.sh
chmod 666 scripts/broken.sh
