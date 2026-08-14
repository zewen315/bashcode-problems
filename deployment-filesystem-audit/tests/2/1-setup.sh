#!/usr/bin/env bash
cd "$1"
mkdir -p releases/v1 config tmp
ln -s releases/v1 current
echo 'running' > releases/v1/app
echo 'secret: abc' > config/secrets.yml
chmod 666 config/secrets.yml
chmod 777 tmp
