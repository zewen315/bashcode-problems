#!/usr/bin/env bash
# $1: path to log file
# Print the top 3 request paths with the most 5xx responses, one per
# line as "<count> <path>", ordered by count descending (ties broken by
# path ascending). Print fewer than 3 lines if fewer paths qualify.
