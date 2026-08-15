#!/usr/bin/env bash
# $1: path to a JSON Lines file, one event object per line:
# {"service": "...", "level": "...", "tags": [...], ...}
# Count events where level is ERROR or CRITICAL and tags contains
# "prod", grouped by service. Print:
# <service>: <count>
# sorted by count descending, then service ascending. Print nothing
# if no event qualifies.
