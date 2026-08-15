#!/usr/bin/env bash
cd "$1"
echo '#!/bin/sh' > weird.sh
chmod 706 weird.sh

echo '#!/bin/sh' > plain.sh
chmod 700 plain.sh
