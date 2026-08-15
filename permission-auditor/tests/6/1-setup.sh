#!/usr/bin/env bash
cd "$1"
echo '#!/bin/sh' > svc-a.sh
chmod 777 svc-a.sh

echo 'data' > svc-b.txt
chmod 666 svc-b.txt

echo '#!/bin/sh' > svc-c.sh
chmod 706 svc-c.sh

echo 'data' > svc-d.txt
chmod 622 svc-d.txt

echo 'data' > svc-e.txt
chmod 644 svc-e.txt

echo '#!/bin/sh' > svc-f.sh
chmod 755 svc-f.sh

echo 'data' > svc-g.txt
chmod 600 svc-g.txt

mkdir releases
chmod 777 releases

ln -s svc-a.sh current
