#!/usr/bin/env bash
# $1: path to a file of operations, one per line: "ADD <name>", "UNDO",
# or "PRINT". ADD records a command; UNDO removes the most recent one
# (no-op if empty); PRINT prints the currently recorded commands,
# oldest first, one per line (nothing if empty).
