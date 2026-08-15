#!/usr/bin/env bash
# $1: path to a directory containing services.txt (manifest, one
# service name per line) and zero or more <name>.status files.
# For each line in services.txt, in order, print:
# <name>: <contents of <name>.status>
# or
# <name>: MISSING
# if that file doesn't exist.
