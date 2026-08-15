#!/usr/bin/env bash
# $1: file. $2: literal substring pattern. $3: N.
# Print the last N lines containing $2 as a substring, in their
# original relative order. Print all matches if fewer than N exist,
# and nothing if there are no matches or N is 0.
