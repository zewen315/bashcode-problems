#!/usr/bin/env bash
# $1: path to a directory of files with real mtimes. Find the *.log
# file directly inside it (no subdirectories) with the latest mtime
# (ties broken alphabetically), then print every line in that one
# file containing "ERROR", in order. Print nothing if there are no
# .log files or the latest one has no ERROR lines.
