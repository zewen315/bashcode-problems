#!/usr/bin/env bash
cd "$1"
cat > only.log <<'LOG'
line one is fine
NOT_AN_ERRORCODE_HANDLER initialized
line three ERRORS out here
all good now
LOG
touch -d '-1 days' only.log
