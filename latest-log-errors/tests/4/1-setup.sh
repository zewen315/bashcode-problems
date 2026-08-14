#!/usr/bin/env bash
cd "$1"
echo 'ERROR from the past' > legacy-import.deadbeef.log
touch -d '2020-06-15 12:00:00' legacy-import.deadbeef.log

echo 'ERROR in web-server' > web-server.ffff0000.log
touch -d '2024-03-01 09:30:00' web-server.ffff0000.log

echo 'ERROR in auth-gateway' > auth-gateway.aaaa1111.log
touch -d '2024-03-01 09:30:00' auth-gateway.aaaa1111.log
