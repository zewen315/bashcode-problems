#!/usr/bin/env bash
# No input file — parse this script's own flags. Each of -n/-v/-o also
# has a long form: --count <n> or --count=<n>, --verbose, --output
# <name> or --output=<name>. Any flag optional, any order, any mix of
# forms; last occurrence wins (default n=0, v=false, o=none). Print:
# n=<...>
# v=<true|false>
# o=<...>
