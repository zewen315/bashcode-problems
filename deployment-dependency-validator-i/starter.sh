#!/usr/bin/env bash
# $1: path to a file of "<service>: <dep1> <dep2> ..." lines. A
# service is "declared" if it appears on the left of a ":" anywhere
# in the file. For every service, for every dependency that's never
# declared, print (once per distinct pair, even if listed twice):
# MISSING: <service> depends on undefined service <other>
# In declaration order, then dependency-list order. Nothing printed
# if everything resolves.
