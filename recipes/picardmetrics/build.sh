#!/bin/bash
set -eu -o pipefail

# Install the picardmetrics script
mkdir -p "${PREFIX}/bin"
cp picardmetrics "${PREFIX}/bin/picardmetrics"
chmod 0755 "${PREFIX}/bin/picardmetrics"

# Install the example config file
mkdir -p "${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"
cp picardmetrics.conf "${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}/picardmetrics.conf"

# Install the man page if present
if [ -d man ]; then
  mkdir -p "${PREFIX}/share/man/man1"
  cp man/*.1 "${PREFIX}/share/man/man1/" 2>/dev/null || true
fi
