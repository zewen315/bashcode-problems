#!/usr/bin/env bash
cd "$1"
mkdir -p a/b/c
printf '%*s' 10 '' > a/b/c/x.log
printf '%*s' 20 '' > a/b/y.log
printf '%*s' 30 '' > a/z.log
