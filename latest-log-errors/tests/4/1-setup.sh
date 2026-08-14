#!/usr/bin/env bash
cd "$1"
echo 'ERROR from the past' > older.log
touch -d '2020-06-15 12:00:00' older.log

echo 'ERROR in zeta' > zeta.log
touch -d '2024-03-01 09:30:00' zeta.log

echo 'ERROR in alpha' > alpha.log
touch -d '2024-03-01 09:30:00' alpha.log
