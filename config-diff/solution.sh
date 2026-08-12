#!/usr/bin/env bash
awk -F= '
  BEGIN { section = 1 }
  $0 == "---" { section = 2; next }
  {
    eq = index($0, "=")
    key = substr($0, 1, eq - 1)
    if (section == 1) { old[key] = $0; oldset[key] = 1 }
    else { new[key] = $0; newset[key] = 1 }
  }
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
' "$1"
