#!/usr/bin/env bash
awk '
  BEGIN { hadError = 0 }
  ARGIND == 1 {
    if ($0 == "") next
    eq = index($0, "=")
    if (eq <= 1) {
      print "Malformed line: " $0
      hadError = 1
      next
    }
    key = substr($0, 1, eq - 1)
    count[key]++
    next
  }
  ARGIND == 2 {
    if ($0 == "") next
    required[$0] = 1
    next
  }
  END {
    ndup = 0
    for (k in count) if (count[k] >= 2) dupKeys[++ndup] = k
    n = asort(dupKeys)
    for (i = 1; i <= n; i++) { print "Duplicate key: " dupKeys[i]; hadError = 1 }

    nmiss = 0
    for (k in required) if (!(k in count)) missKeys[++nmiss] = k
    m = asort(missKeys)
    for (i = 1; i <= m; i++) { print "Missing required key: " missKeys[i]; hadError = 1 }

    if (!hadError) print "VALID"
  }
' "$1" "$2"
