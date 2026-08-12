#!/usr/bin/env bash
awk -F'[.-]' '$2 == "prod" { print $1 }' "$1" | sort -u
