#!/usr/bin/env bash
cd "$1"
echo 'data' > one.txt
chmod 644 one.txt

echo '#!/bin/sh' > two.sh
chmod 755 two.sh

echo 'data' > three.txt
chmod 665 three.txt

echo 'data' > four.txt
chmod 600 four.txt
