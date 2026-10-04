#!/bin/sh
# Runs ahead of the vendor's /entrypoint.sh. OpenCloud always serves https, and
# a browser refuses to load an http editor into an https page, so without a
# certificate the editor area in OpenCloud just stays blank. Unless a usable
# certificate is configured, this creates a self-signed one in Data, where it
# survives container updates, and passes its paths on; the vendor entrypoint
# then starts its own https listener on port 443.
set -eu

CERT_DIR="/var/www/euro-office/Data/certs"
cert="${SSL_CERTIFICATE_PATH:-}"
key="${SSL_KEY_PATH:-}"

if [ "${AUTO_TLS:-true}" = "true" ] && ! { [ -f "${cert}" ] && [ -f "${key}" ]; }; then
    # The vendor entrypoint skips TLS without a word when a path is missing.
    if [ -n "${cert}${key}" ]; then
        echo "[auto-tls] WARNING: TLS certificate '${cert}' or key '${key}' is not set or does not exist, using the self-signed certificate instead"
    fi
    if [ ! -s "${CERT_DIR}/tls.crt" ] || [ ! -s "${CERT_DIR}/tls.key" ]; then
        mkdir -p "${CERT_DIR}"
        openssl req -x509 -newkey rsa:2048 -nodes -days 3650 \
            -subj "/CN=euro-office" -addext "subjectAltName=DNS:euro-office" \
            -keyout "${CERT_DIR}/tls.key" -out "${CERT_DIR}/tls.crt" 2>/dev/null
        echo "[auto-tls] created a self-signed certificate in ${CERT_DIR}"
    fi
    export SSL_CERTIFICATE_PATH="${CERT_DIR}/tls.crt"
    export SSL_KEY_PATH="${CERT_DIR}/tls.key"
fi

exec /entrypoint.sh "$@"
