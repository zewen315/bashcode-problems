#!/usr/bin/env bash
# $1: path to a file of "<name> <ip> <port>" lines
# Print the line number (1-indexed) of every line that does not have
# exactly 3 fields, or whose 3rd field isn't all digits, one per line,
# in ascending order. Print nothing if every line is valid.
