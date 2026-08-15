#!/usr/bin/env bash
# $1: path to a log file. Print every line, with:
# - password=/secret=/token=/api_key= values (case-insensitive key,
#   standalone word only) replaced with REDACTED
# - 16-digit card numbers (bare, hyphen-grouped, or space-grouped
#   4x4, not part of a longer digit run) replaced with REDACTED_CC
