#!/usr/bin/env bash
set -euo pipefail

# Install entrypoints
install -d "${PREFIX}/bin"
install -m 0755 "bin/metastrand" "${PREFIX}/bin/metastrand"

# Install package data (scripts, templates, README)
install -d "${PREFIX}/share/metastrand"
install -d "${PREFIX}/share/metastrand/scripts"

cp -R "scripts/." "${PREFIX}/share/metastrand/scripts/"

# Optional: template config
if [[ -f "config.template.txt" ]]; then
  install -m 0644 "config.template.txt" "${PREFIX}/share/metastrand/config.template.txt"
fi
if [[ -f "config.test.txt" ]]; then
  install -m 0644 "config.test.txt" "${PREFIX}/share/metastrand/config.test.txt"
fi
