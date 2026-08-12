#!/usr/bin/env bash
# $1: path to the template file
# $2: path to the variables file, "<KEY>=<VALUE>" one per line
# Print the template with every "{{KEY}}" replaced by its value from
# the variables file. Leave placeholders whose key isn't defined
# unchanged (braces included). Values must be substituted literally —
# don't treat them as patterns.
