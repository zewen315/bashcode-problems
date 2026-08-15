#!/usr/bin/env bash
# $1: path to a file of "<pid> <ppid> <state> <cmd>" lines. Group
# every state==Z process by ppid; look up ppid as a pid elsewhere in
# the file for the parent's cmd (UNKNOWN if not found, regardless of
# that parent's own state). Print:
# PARENT <ppid> (<parent_cmd>): <count> zombies
#   <pid> <cmd>
# ...one block per parent, sorted by count desc then ppid asc; each
# group's children sorted by pid asc. Nothing printed if no zombies.
