#!/usr/bin/env bash
history=()
while IFS= read -r line; do
  case "$line" in
    ADD\ *)
      history+=("${line#ADD }")
      ;;
    UNDO)
      [ "${#history[@]}" -gt 0 ] && unset 'history[-1]' && history=("${history[@]}")
      ;;
    PRINT)
      [ "${#history[@]}" -gt 0 ] && printf '%s\n' "${history[@]}"
      ;;
  esac
done < "$1"
