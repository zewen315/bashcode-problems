#!/usr/bin/env bash
# $1: path to a directory. For every regular file directly inside it:
# flag it "dangerous" if the other-write bit is set AND any execute
# bit (owner/group/other) is set; otherwise flag it "world-writable"
# if just the other-write bit is set. Skip subdirectories and
# symlinks entirely. Print:
# FLAG: dangerous <name>
# then
# FLAG: world-writable <name>
# each group sorted alphabetically. Print nothing if nothing qualifies.
