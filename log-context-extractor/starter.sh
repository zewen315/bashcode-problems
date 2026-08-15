#!/usr/bin/env bash
# $1: log file path. $2: literal substring pattern. $3: context size N.
# Reproduce grep -n -C "$3" -F "$2" "$1":
# - matching line: <line number>:<content>
# - context-only line: <line number>-<content>
# Merge overlapping/adjacent match windows into one block; print a
# line containing exactly -- between separate blocks. Nothing printed
# if there's no match.
