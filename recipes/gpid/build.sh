#!/usr/bin/env bash
set -euo pipefail

install -d "${PREFIX}/bin"
install -d "${PREFIX}/share/gpid"
install -d "${PREFIX}/share/gpid/scripts"
install -d "${PREFIX}/share/gpid/templates"

install -m 0755 gpid "${PREFIX}/share/gpid/"
install -m 0755 scripts/reference.sh scripts/calibrate.sh scripts/validate.sh scripts/identify.sh "${PREFIX}/share/gpid/scripts/"
install -m 0644 scripts/*.R "${PREFIX}/share/gpid/scripts/"
install -m 0644 templates/*.csv "${PREFIX}/share/gpid/templates/"
install -m 0644 VERSION LICENSE "${PREFIX}/share/gpid/"

cat > "${PREFIX}/bin/gpid" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PREFIX_DIR=$(cd "${SCRIPT_DIR}/.." && pwd)

exec bash "${PREFIX_DIR}/share/gpid/gpid" "$@"
EOF

chmod 0755 "${PREFIX}/bin/gpid"
