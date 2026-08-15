#!/usr/bin/env bash
# $1: path to a text file, whitespace-separated tokens per line.
# Find every token that is a valid IPv4 address: exactly 4 dot-
# separated octets, each 0-255, no leading zeros (0 itself is fine).
# For every line with at least one match, print:
# <line number>: <ip1> <ip2> ...
# in the order the IPs appear. Omit lines with no match.
