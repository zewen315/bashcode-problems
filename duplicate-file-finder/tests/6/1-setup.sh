#!/usr/bin/env bash
cd "$1"
mkdir -p logs backups configs
echo 'config data v1' > configs/app.conf
echo 'config data v1' > backups/app.conf.bak
echo 'log entry' > logs/app.log
echo 'log entry' > logs/app2.log
echo 'log entry' > backups/old.log
touch logs/empty.log
touch backups/empty.bak
echo 'unique config' > configs/other.conf
