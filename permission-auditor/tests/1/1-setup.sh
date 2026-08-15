#!/usr/bin/env bash
cd "$1"
echo 'readme' > readme.md
chmod 644 readme.md

echo '#!/bin/sh' > start.sh
chmod 755 start.sh

echo '#!/bin/sh' > backup.sh
chmod 777 backup.sh

echo 'shared' > shared.txt
chmod 666 shared.txt
