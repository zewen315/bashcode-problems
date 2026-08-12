#!/usr/bin/env bash
# $1: path to a process listing file, header "PID USER ELAPSED COMMAND"
# Print "<PID> <COMMAND>" for every process with ELAPSED > 3600,
# sorted longest-running to shortest-running (ties broken by PID
# ascending).
