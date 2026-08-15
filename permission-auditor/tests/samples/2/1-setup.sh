#!/usr/bin/env bash
cd "$1"
echo 'settings' > app.conf
chmod 644 app.conf

echo 'private' > notes.txt
chmod 600 notes.txt

mkdir releases
chmod 777 releases

ln -s releases current
