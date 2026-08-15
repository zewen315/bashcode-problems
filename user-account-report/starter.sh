#!/usr/bin/env bash
# $1: path to a /etc/passwd-style file, 7 ":"-delimited fields per
# line: username:password:uid:gid:gecos:home:shell.
# For every line whose shell's last path component isn't exactly
# "nologin" or "false", print "<username> <home> <shell>", in order.
# Omit no-login lines entirely.
