#!/usr/bin/env bash
cd "$1"
echo '#!/bin/sh' > zeta.sh
chmod 777 zeta.sh

echo '#!/bin/sh' > alpha.sh
chmod 777 alpha.sh

echo 'data' > delta.txt
chmod 666 delta.txt

echo 'data' > bravo.txt
chmod 666 bravo.txt
