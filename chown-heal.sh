#!/bin/sh
# Hands the Euro Office Data dir to the `ds` user its services run as (see the
# Dockerfile for why upstream leaves it owned by root).
#
# The vendor's entrypoint.sh creates Data/.private and the WOPI keypair as root
# and only then execs supervisord, so this program (priority=1, ahead of the
# ds-* services) keeps re-chowning for 30s instead of running once. Data holds
# a few key files, so that costs nothing.
#
# The ids are looked up at runtime because the upstream .deb creates `ds` with
# `adduser --system`, so its numbers can change between image rebuilds.
set -eu

DATA_DIR="/var/www/euro-office/Data"
DS_UID="$(id -u ds 2>/dev/null || echo 105)"
DS_GID="$(id -g ds 2>/dev/null || echo 107)"

mkdir -p "${DATA_DIR}"
echo "[chown-heal] healing ${DATA_DIR} ownership to ${DS_UID}:${DS_GID} (the 'ds' user every docservice/adminpanel/converter process runs as)"

i=0
while [ "${i}" -lt 15 ]; do
    chown -R "${DS_UID}:${DS_GID}" "${DATA_DIR}" 2>/dev/null || true
    i=$((i + 1))
    sleep 2
done

echo "[chown-heal] done: Data ownership settled"
/usr/local/bin/print-banner.sh "Euro Office wrapper" "Permission heal complete, Euro Office's own services boot separately below"
