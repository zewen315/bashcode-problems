#!/usr/bin/env bash
# $1: path to a directory tree (may be nested). Group regular files
# by content (empty files never count, even against each other).
# For every group of 2+ files, print:
# DUPLICATE: <path1> <path2> ... <pathN>
# Paths relative to $1, sorted within the group; groups sorted by
# their smallest path. Nothing printed if there are no duplicates.
