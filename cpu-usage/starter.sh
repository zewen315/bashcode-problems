#!/usr/bin/env bash
# $1: path to a file of "<service> <cpu_usage>" lines.
# Print "ALL HEALTHY" if no service is >= 80. Otherwise print
# "High CPU: <service1> <service2> ..." (>= 80, in input order) then
# "Critical: <count>" (services >= 90).
