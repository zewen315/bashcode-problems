#!/usr/bin/env bash
awk 'NF != 3 || $3 !~ /^[0-9]+$/ { print NR }' "$1"
