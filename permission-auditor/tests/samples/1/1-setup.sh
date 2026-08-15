#!/usr/bin/env bash
cd "$1"
echo 'settings' > config.yaml
chmod 644 config.yaml

echo '#!/bin/sh' > deploy.sh
chmod 777 deploy.sh

echo 'API_KEY=x' > secrets.env
chmod 666 secrets.env
