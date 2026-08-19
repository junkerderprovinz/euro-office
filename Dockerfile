# syntax=docker/dockerfile:1
# =============================================================================
# euro-office - one-click Euro Office (OnlyOffice-fork document server)
# wrapper image for Unraid.
#
# A thin wrapper around the official Euro Office Document Server image. The
# upstream image's own build has a `chown -R ds:ds .../Data` step commented
# out (build/.docker/standalone.bake.Dockerfile in euro-office/documentserver),
# so a bind-mounted Data volume (WOPI keys, JWT secret, runtime state) stays
# owned by whoever created it - root, via the vendor's entrypoint.sh, on every
# boot - while the docservice/adminpanel/converter services all run as the
# unprivileged `ds` user. Result: EACCES on Data/runtime.json and friends the
# moment those services try to read/write their own state
# (github.com/junkerderprovinz/unraid-apps#7). Reported upstream:
# github.com/euro-office/documentserver#<issue-number-filled-in-after-filing>.
#
# This wrapper does NOT touch ENTRYPOINT or the vendor's own entrypoint.sh -
# it only adds one extra supervisor program (chown-heal, priority=1, so it
# starts before the ds-* services) that re-asserts Data's ownership to the
# `ds` user for the first ~30s of boot. That safely covers the file-creation
# race (entrypoint.sh creates .private/ + the WOPI keypair as root, then execs
# supervisord) without forking/maintaining a modified copy of the vendor's own
# boot script.
#
# Licensing: this wrapper (Dockerfile + scripts + banner) is AGPL-3.0-only;
# the Euro Office binary baked into the base image is licensed by Euro
# Office - see their own repository for terms. See LICENSE / NOTICE.
# =============================================================================

ARG BASE=ghcr.io/euro-office/documentserver:latest

# hadolint ignore=DL3006
FROM ${BASE}

# OCI provenance. Wrapper assets = MIT; the bundled Euro Office binary is
# licensed separately by Euro Office.
LABEL org.opencontainers.image.title="euro-office (Unraid wrapper)" \
      org.opencontainers.image.description="One-click Euro Office document server for Unraid - fixes a real upstream Data-volume permission gap." \
      org.opencontainers.image.source="https://github.com/junkerderprovinz/euro-office" \
      org.opencontainers.image.licenses="AGPL-3.0-only" \
      org.opencontainers.image.vendor="junkerderprovinz"

# Our extra supervisor program + the shared house log banner. The base image
# is Ubuntu 24.04 and its Dockerfile has no USER directive, so we are already
# root here (needed to write under /etc/supervisor/conf.d and /usr/local/bin).
COPY chown-heal.sh print-banner.sh /usr/local/bin/
COPY chown-heal.conf /etc/supervisor/conf.d/00-chown-heal.conf
COPY .github/assets/banner-raw.txt /usr/local/share/banner-raw.txt

# Install the shared banner art (strip any CRLF -> a clean log block; the
# scripts themselves are LF via .gitattributes) and make everything executable.
RUN tr -d '\r' < /usr/local/share/banner-raw.txt > /usr/local/share/banner.txt \
 && rm /usr/local/share/banner-raw.txt \
 && chmod +x /usr/local/bin/chown-heal.sh /usr/local/bin/print-banner.sh

# Base image's own ENTRYPOINT and CMD are untouched - supervisord picks up our
# extra program from the conf file above alongside its own.
