#!/usr/bin/env bash
# $1: path to the config file
# $2: path to the required-keys file, one key per line
# Print, in order: "Malformed line: ..." for lines with no "=" or an
# empty key (file order), then "Duplicate key: ..." for keys that
# appear more than once (alphabetical), then "Missing required key:
# ..." for required keys never present (alphabetical). If none of
# those apply, print exactly "VALID".
