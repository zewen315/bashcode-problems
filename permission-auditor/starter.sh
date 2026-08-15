#!/usr/bin/env bash
# $1: path to a file of "<perms> <links> <owner> <group> <size> <name>"
# lines (ls -l style). For type "-" (regular file) entries: flag
# world-writable ones (position 9 of perms is "w"), or "dangerous" if
# also executable anywhere (position 4, 7, or 10 is "x") — dangerous
# takes priority, never both. Skip directories, symlinks, and
# malformed lines. Print "FLAG: dangerous <name>" lines first, then
# "FLAG: world-writable <name>" lines, each group sorted by name.
