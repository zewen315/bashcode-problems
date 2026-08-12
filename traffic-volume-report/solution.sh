#!/usr/bin/env bash
awk '$2 * $3 > 50000 { print $1, $2 * $3 }' "$1" | sort -k2,2nr -k1,1
