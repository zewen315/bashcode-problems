#!/usr/bin/env bash
cd "$1"
mkdir -p releases/v1 releases/v2 releases/v3/nested scripts config logs

ln -s releases/v3 current
ln -s releases/v1/missing releases/v2/link-to-nowhere

touch releases/v3/nested/build.artifact
touch logs/empty.log

echo 'v3 release notes' > releases/v3/README.md

cat > scripts/start.sh <<'SH'
#!/bin/sh
echo start
SH
chmod 755 scripts/start.sh

touch scripts/stop.sh
chmod 644 scripts/stop.sh

cat > releases/v3/nested/migrate.sh <<'SH'
#!/bin/sh
echo migrate
SH
chmod 644 releases/v3/nested/migrate.sh

chmod 777 config
echo 'insecure' > logs/access.log
chmod 666 logs/access.log

# Owner has execute, but group/other don't (744) — the owner-execute
# bit IS set, so this must NOT be flagged, even though whoever runs
# the audit is never this file's owner.
cat > scripts/admin-only.sh <<'SH'
#!/bin/sh
echo admin
SH
chmod 744 scripts/admin-only.sh
