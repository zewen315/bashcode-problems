#!/usr/bin/env bash
# $1: path to a file of "<service>: <dep1> <dep2> ..." lines.
# $2: path to a file listing services one per line, in the order
# they're attempted to start. A service starts only if every one of
# its dependencies already started earlier in the simulation (a
# scheduled-later, never-attempted, or itself-failed dependency all
# count as "not started" — no second chances, failures cascade).
# For each failed service, one line per unmet dependency, in that
# service's own declared order:
# MISSING: <service> depends on <dep>, which never started
# If everything attempted starts, print:
# ALL SERVICES STARTED
