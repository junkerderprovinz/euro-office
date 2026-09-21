# syntax=docker/dockerfile:1@sha256:ecfaec9ed6d810b56388c508f4121597bfbba70d41a6dfeee4d8cad5f295fc32
# Unraid wrapper around the Euro Office Document Server image.
#
# The upstream build has its `chown -R ds:ds .../Data` step commented out
# (build/.docker/standalone.bake.Dockerfile in euro-office/documentserver), so a
# bind-mounted Data volume stays owned by root, while the docservice, adminpanel
# and converter services run as `ds` and fail with EACCES on their own state
# (junkerderprovinz/unraid-apps#7). chown-heal.sh fixes the ownership from an
# extra supervisor program, which leaves ENTRYPOINT and the vendor's
# entrypoint.sh untouched.
#
# Licensing: this wrapper (Dockerfile, scripts, banner) is AGPL-3.0-only; the
# Euro Office binary in the base image is licensed by Euro Office. See LICENSE
# and NOTICE.

ARG BASE=ghcr.io/euro-office/documentserver:latest

# hadolint ignore=DL3006
FROM ${BASE}

LABEL org.opencontainers.image.title="euro-office (Unraid wrapper)" \
      org.opencontainers.image.description="One-click Euro Office document server for Unraid - fixes a real upstream Data-volume permission gap." \
      org.opencontainers.image.source="https://github.com/junkerderprovinz/euro-office" \
      org.opencontainers.image.licenses="AGPL-3.0-only" \
      org.opencontainers.image.vendor="junkerderprovinz"

# The base image sets no USER, so these steps run as root. Supervisord picks up
# the conf file alongside the vendor's own programs.
COPY chown-heal.sh print-banner.sh /usr/local/bin/
COPY chown-heal.conf /etc/supervisor/conf.d/00-chown-heal.conf
COPY .github/assets/banner-raw.txt /usr/local/share/banner-raw.txt

# A stray CR in the banner art would show up in the log.
RUN tr -d '\r' < /usr/local/share/banner-raw.txt > /usr/local/share/banner.txt \
 && rm /usr/local/share/banner-raw.txt \
 && chmod +x /usr/local/bin/chown-heal.sh /usr/local/bin/print-banner.sh
