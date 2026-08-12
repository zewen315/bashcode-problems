#!/usr/bin/env bash
awk '$(NF-1) ~ /^5[0-9][0-9]$/ {print $(NF-3)}' "$1" |
  sort |
  uniq -c |
  sort -k1,1nr -k2,2 |
  head -n 3 |
  awk '{print $1, $2}'
