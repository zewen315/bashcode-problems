#!/usr/bin/env bash
# $1: path to a file of "<timestamp> <user>" lines, sorted by time.
# Each user may make at most 2 requests in any rolling 5-second
# window (counting only requests that were themselves allowed).
# Print every line back with " ALLOWED" or " BLOCKED" appended.
