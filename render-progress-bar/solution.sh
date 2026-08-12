#!/usr/bin/env bash
awk '{
  name = $1
  pct = $2
  filled = int(pct * 20 / 100 + 0.5)
  bar = ""
  for (i = 0; i < filled; i++) bar = bar "#"
  for (i = filled; i < 20; i++) bar = bar "-"
  print name, "[" bar "]", pct "%"
}' "$1"
