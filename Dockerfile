# syntax=docker/dockerfile:1@sha256:4edf897a3ffa55b89f906fc8cc78afdb3f1834cc9c7083565e611a8a7d5fe99e
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
COPY auto-tls.sh chown-heal.sh print-banner.sh /usr/local/bin/
COPY chown-heal.conf /etc/supervisor/conf.d/00-chown-heal.conf
COPY .github/assets/banner-raw.txt /usr/local/share/banner-raw.txt
# The vendor's start page explains the test example and the admin panel, which
# are both switched off here and only lead people away from OpenCloud. The
# vendor entrypoint points the index at docker.html, the build default is
# linux.html.
COPY welcome.html /var/www/euro-office/documentserver-example/welcome/docker.html
COPY welcome.html /var/www/euro-office/documentserver-example/welcome/linux.html

# A stray CR in the banner art would show up in the log. With a certificate the
# vendor's port 80 server only redirects to https://$host, which drops the
# mapped port and lands on the Unraid web UI, so it serves the editor instead;
# that also keeps every existing http setup working. The grep fails the build
# if upstream changes the template under us.
ARG SSL_TMPL=/etc/euro-office/documentserver/nginx/ds-ssl.conf.tmpl
RUN tr -d '\r' < /usr/local/share/banner-raw.txt > /usr/local/share/banner.txt \
 && rm /usr/local/share/banner-raw.txt \
 && sed -i \
      -e '/## Redirects all traffic to the HTTPS host/d' \
      -e '/root \/nowhere;/d' \
      -e 's|rewrite ^ https://$host$request_uri? permanent;|include /etc/nginx/includes/ds-*.conf;|' \
      "${SSL_TMPL}" \
 && ! grep -q 'rewrite ^ https' "${SSL_TMPL}" \
 && chmod +x /usr/local/bin/auto-tls.sh /usr/local/bin/chown-heal.sh /usr/local/bin/print-banner.sh

ENTRYPOINT ["/usr/local/bin/auto-tls.sh"]
