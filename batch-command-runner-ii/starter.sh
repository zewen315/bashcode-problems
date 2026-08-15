#!/usr/bin/env bash
# $1: hosts file, one host per line. $2: batch size.
# $3: command to run. $4...: that command's existing arguments.
# Run "$3 $4... <batch hosts>" once per batch (preserving argument
# boundaries, no eval). Stop and exit with the same status the
# moment a batch's command exits non-zero. Exit 0 if all succeed.
# Don't run anything if the hosts file is empty.
