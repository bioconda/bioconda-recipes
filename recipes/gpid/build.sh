#!/usr/bin/env bash
# --- Purpose ---
# Install GPID workflows and helpers, using the recipe version for the runtime banner.
set -euo pipefail

# --- Create installation directories ---
install -d "${PREFIX}/bin"
install -d "${PREFIX}/share/gpid"
install -d "${PREFIX}/share/gpid/scripts"

# --- Install workflows and shared R/AWK helpers ---
install -m 0755 gpid "${PREFIX}/share/gpid/"
install -m 0755 scripts/reference.sh scripts/calibrate.sh scripts/confidence.sh scripts/identify.sh "${PREFIX}/share/gpid/scripts/"
install -m 0644 scripts/*.R "${PREFIX}/share/gpid/scripts/"
install -m 0644 scripts/*.awk "${PREFIX}/share/gpid/scripts/"
install -m 0644 LICENSE CHANGELOG.md "${PREFIX}/share/gpid/"

# Conda supplies the version declared in meta.yaml; no source VERSION file is needed.
printf '%s\n' "${PKG_VERSION}" > "${PREFIX}/share/gpid/VERSION"
chmod 0644 "${PREFIX}/share/gpid/VERSION"

# --- Create the launcher relative to the installed prefix ---
cat > "${PREFIX}/bin/gpid" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PREFIX_DIR=$(cd "${SCRIPT_DIR}/.." && pwd)

exec bash "${PREFIX_DIR}/share/gpid/gpid" "$@"
EOF

chmod 0755 "${PREFIX}/bin/gpid"
