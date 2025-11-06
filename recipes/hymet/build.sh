#!/bin/bash
set -euo pipefail

HYMET_VERSION="${PKG_VERSION:-unknown}"
HYMET_ROOT="$PREFIX/share/hymet"
SRC_DIR="${SRC_DIR:-$PWD}"

rm -rf "${HYMET_ROOT}"
mkdir -p "${HYMET_ROOT}"

# Copy the complete HYMET repository so the Python CLI can locate bench/case assets.
cp -a "${SRC_DIR}/." "${HYMET_ROOT}"

install -d "${PREFIX}/bin"

cat <<EOF > "${PREFIX}/bin/hymet"
#!/bin/bash
set -euo pipefail
ROOT="\${HYMET_ROOT:-${HYMET_ROOT}}"
export HYMET_ROOT="\${ROOT}"
export HYMET_VERSION="\${HYMET_VERSION:-${HYMET_VERSION}}"
exec python "\${ROOT}/bin/hymet" "\$@"
EOF
chmod +x "${PREFIX}/bin/hymet"

cat <<EOF > "${PREFIX}/bin/hymet-config"
#!/bin/bash
set -euo pipefail
ROOT="\${HYMET_ROOT:-${HYMET_ROOT}}"
cd "\${ROOT}"
exec perl config.pl "\$@"
EOF
chmod +x "${PREFIX}/bin/hymet-config"

cat <<EOF > "${PREFIX}/bin/hymet-legacy"
#!/bin/bash
set -euo pipefail
ROOT="\${HYMET_ROOT:-${HYMET_ROOT}}"
cd "\${ROOT}"
exec perl main.pl "\$@"
EOF
chmod +x "${PREFIX}/bin/hymet-legacy"
