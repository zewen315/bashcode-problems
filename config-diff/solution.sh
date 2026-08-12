#!/usr/bin/env bash
# $1: path to the old config, $2: path to the new config
awk -F= '
  { eq = index($0, "="); key = substr($0, 1, eq - 1) }
  ARGIND == 1 { old[key] = $0; oldset[key] = 1 }
  ARGIND == 2 { new[key] = $0; newset[key] = 1 }
  END {
    for (k in oldset) all[k] = 1
    for (k in newset) all[k] = 1
    n = asorti(all, sorted)
    for (i = 1; i <= n; i++) {
      k = sorted[i]
      if ((k in oldset) && (k in newset)) {
        if (old[k] != new[k]) {
          print "- " old[k]
          print "+ " new[k]
        }
      } else if (k in oldset) {
        print "- " old[k]
      } else {
        print "+ " new[k]
      }
    }
  }
' "$1" "$2"
