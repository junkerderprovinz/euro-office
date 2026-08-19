#!/bin/sh
# -----------------------------------------------------------------------------
# print-banner.sh <container-name> <subtitle>
# Shared Junker-der-Provinz init-log banner (POSIX sh - the base image is
# Ubuntu but the script stays sh-only so it matches every other house image).
# The ASCII art in /usr/local/share/banner.txt is identical across all
# container images; the name + subtitle are passed at runtime so the shared
# art stays generic.
# -----------------------------------------------------------------------------
CONTAINER="${1:-Container}"
SUBTITLE="${2:-}"
BANNER_FILE="/usr/local/share/banner.txt"

echo ""

if [ -f "${BANNER_FILE}" ]; then
    cat "${BANNER_FILE}"
    # The shared banner file has no trailing newline; add blank lines so the
    # banner gets breathing room before the title block.
    echo ""
    echo ""
else
    echo ""
    echo "  Junker der Provinz"
    echo ""
fi

# Clean title block: name + subtitle on ONE line (house look, no rules).
if [ -n "${SUBTITLE}" ]; then
    printf '  %s · %s\n' "${CONTAINER}" "${SUBTITLE}"
else
    printf '  %s\n' "${CONTAINER}"
fi
echo ""
