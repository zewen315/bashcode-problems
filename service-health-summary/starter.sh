#!/usr/bin/env bash
# $1: path to a JSON file: {"services": [{"name":..., "instances":
# [{"id":..., "status":...}, ...]}, ...]}. For every service with at
# least one instance whose status isn't "healthy", print:
# <service name>: <id1> <id2> ...
# listing just the non-healthy instance ids, in order. Services that
# are fully healthy (or have no instances) are omitted.
