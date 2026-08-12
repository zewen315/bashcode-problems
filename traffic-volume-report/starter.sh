#!/usr/bin/env bash
# $1: path to the traffic data file, "<server> <requests_per_second> <duration_seconds>"
# Print "<server> <total_requests>" for every server whose
# requests_per_second * duration_seconds is greater than 50000, sorted
# by total_requests descending (ties broken by server name ascending).
