#!/usr/bin/env bash
# $1: path to a directory tree (may be nested). Recursively report:
# BROKEN_SYMLINK <path>  - a symlink whose target doesn't exist
# EMPTY_FILE <path>      - a zero-byte regular file
# NOT_EXECUTABLE <path>  - a *.sh file missing the owner-execute bit
# WORLD_WRITABLE <path>  - a file or dir (never a symlink) that's
#                          world-writable
# One line per finding, path relative to $1 (no leading "./"), sorted
# by path then by check name for ties. Nothing printed if no findings.
