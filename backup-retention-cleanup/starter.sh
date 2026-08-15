#!/usr/bin/env bash
# $1: path to a directory of backup files (flat, no subdirectories).
# Policy: max age 30 days, always keep the 3 most-recently-modified
# files regardless of age. Print, sorted alphabetically:
# DELETE: <filename>
# for each file safe to delete. If none qualify, print exactly:
# NOTHING TO DELETE
