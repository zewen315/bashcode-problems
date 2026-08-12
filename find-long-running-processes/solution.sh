#!/usr/bin/env bash
awk 'NR > 1 && $3 > 3600 { print $3, $1, $4 }' "$1" | sort -k1,1nr -k2,2n | awk '{print $2, $3}'
