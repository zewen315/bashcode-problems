#!/usr/bin/env bash
# $1: path to a file of operations, one per line: "SET <service>
# <version>", "GET <service>", or "DELETE <service>". SET records a
# service's version, overwriting any previous one. GET prints the
# service's current version, or "NOT FOUND" if it has none. DELETE
# removes a service's recorded version (no-op if it has none).
