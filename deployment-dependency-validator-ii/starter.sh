#!/usr/bin/env bash
# $1: path to a file of "<service>: <dep1> <dep2> ..." lines (every
# dependency is guaranteed declared). DFS from unvisited services in
# alphabetical order; within one DFS, visit dependencies in the order
# they're listed. The first time a dependency is found already on the
# CURRENT search path, that's the cycle — report it and stop:
# CYCLE: <service> -> <service> -> ... -> <service>
# starting from where the path first revisits, ending back at that
# same service. Print nothing if there's no cycle.
