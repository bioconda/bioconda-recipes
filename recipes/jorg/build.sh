#!/usr/bin/env bash
set -euo pipefail

mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/share/jorg"

# Install current upstream script and manifest
install -m 0755 jorg "${PREFIX}/bin/jorg"
install -m 644 Example/manifest_template.conf "${PREFIX}/share/jorg/manifest_template.conf"

# Patch the installed script so it can find the packaged manifest
sed -i '1 a\
JORG_SHARE_DIR="${JORG_SHARE_DIR:-'"${PREFIX}"'/share/jorg}"\
MANIFEST_TEMPLATE="${JORG_SHARE_DIR}/manifest_template.conf"
' "${PREFIX}/bin/jorg"

# Replace the upstream "current directory" manifest check
sed -i 's|if \[ ! -e "manifest_template.conf" \]|if [ ! -f "$MANIFEST_TEMPLATE" ]|g' "${PREFIX}/bin/jorg"
sed -i 's|echo "Missing manifest_template.conf file.  Copy it into current directory."|echo "Missing manifest template: $MANIFEST_TEMPLATE"|g' "${PREFIX}/bin/jorg"

# Replace manifest generation line to use packaged template
sed -i 's#cat manifest_template.conf | sed "s/XXX/$binID/g" > manifest.conf#sed "s/XXX/$binID/g" "$MANIFEST_TEMPLATE" > manifest.conf#g' "${PREFIX}/bin/jorg"
