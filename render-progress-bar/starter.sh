#!/usr/bin/env bash
# $1: path to a file of "<name> <percent>" lines
# For each line, in order, print "<name> [<bar>] <percent>%" where bar
# is a 20-character-wide bar of '#' (completed) and '-' (remaining),
# with the '#' count equal to percent scaled to 20 and rounded to the
# nearest integer.
