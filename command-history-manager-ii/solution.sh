#!/usr/bin/env bash
declare -A version
while read -r cmd a b; do
  case "$cmd" in
    SET)    version[$a]=$b ;;
    DELETE) unset "version[$a]" ;;
    GET)    echo "${version[$a]:-NOT FOUND}" ;;
  esac
done < "$1"
