#!/bin/sh
# =============================================================================
# chown-heal.sh - fixes a real upstream gap: euro-office/documentserver's own
# build removes its `chown -R ds:ds .../Data` step (commented out in their
# Dockerfile), and entrypoint.sh creates Data/.private + the WOPI keypair as
# root on every boot. The docservice/adminpanel/converter services all run as
# the unprivileged `ds` user (see ds-*.conf under /etc/supervisor/conf.d), so
# on a fresh bind-mounted Data volume they get EACCES trying to read/write
# their own secrets and runtime state.
#
# Runs as its own supervisor program (priority=1, so it starts before the
# ds-* services) rather than folding into ENTRYPOINT: entrypoint.sh
# (vendor-owned, still runs completely unmodified, still creates .private/
# the keys as root) execs supervisord as its last step, so this only gets a
# shot at fixing ownership AFTER those files already exist - hence the short
# retry loop below instead of a single pass. The Data dir is tiny (a couple
# of key files), so re-chowning every 2s for 30s is effectively free and
# safely covers the race regardless of exact supervisor timing.
#
# The `ds` uid/gid is resolved at runtime, not hardcoded: it's a
# dynamically-allocated Debian system user (`adduser --system` in the
# upstream .deb postinst), not guaranteed to be the same number across image
# rebuilds.
# =============================================================================
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

echo "[chown-heal] done - Data ownership settled"
/usr/local/bin/print-banner.sh "Euro Office wrapper" "Permission heal complete - Euro Office's own services boot separately below"
