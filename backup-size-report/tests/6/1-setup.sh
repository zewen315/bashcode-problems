#!/usr/bin/env bash
cd "$1"
mkdir -p svc1 svc2 svc3
printf '%*s' 1000 '' > svc1/a.log
printf '%*s' 2500 '' > svc1/b.log
printf '%*s' 300 '' > svc2/c.log
printf '%*s' 42 '' > svc2/notes.md
printf '%*s' 777 '' > svc3/d.log
printf '%*s' 15 '' > svc3/e.log
