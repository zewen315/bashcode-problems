#!/usr/bin/env bash
# $1: template, $2: variables — passed to awk in the opposite order so
# the variables file (which must be fully loaded first) is ARGIND==1.
awk -F= '
  ARGIND == 1 { vars[$1] = substr($0, length($1) + 2); next }
  ARGIND == 2 {
    line = $0
    result = ""
    while (match(line, /\{\{[A-Za-z0-9_]+\}\}/)) {
      key = substr(line, RSTART + 2, RLENGTH - 4)
      prefix = substr(line, 1, RSTART - 1)
      repl = (key in vars) ? vars[key] : substr(line, RSTART, RLENGTH)
      result = result prefix repl
      line = substr(line, RSTART + RLENGTH)
    }
    print result line
  }
' "$2" "$1"
