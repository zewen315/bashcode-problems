#!/usr/bin/env bash
cd "$1"
mkdir -p logs archive
printf '%*s' 120 '' > logs/app.log
printf '%*s' 340 '' > logs/error.log
printf '%*s' 50 '' > logs/readme.txt
printf '%*s' 75 '' > archive/old.log
