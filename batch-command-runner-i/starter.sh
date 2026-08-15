#!/usr/bin/env bash
# $1: path to a hosts file, one host per line. $2: batch size.
# Group hosts (in file order) into batches of at most $2, and print
# one line per batch:
# deploy <host1> <host2> ...
# The final batch may be smaller. Print nothing for an empty file.
