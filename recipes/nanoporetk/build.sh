#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="${PREFIX}/share/nanoporetk"

echo "[INFO] Installing nanoporeTK"
echo "[INFO] Source:  ${SRC_DIR}"
echo "[INFO] Target:  ${INSTALL_DIR}"

mkdir -p "${INSTALL_DIR}"
mkdir -p "${PREFIX}/bin"

# Install the complete nanoporeTK tree.
cp -R . "${INSTALL_DIR}/"

# Ensure the real entrypoint is executable.
chmod 0755 "${INSTALL_DIR}/nanoporeTK"

echo "[INFO] Creating command wrapper: ${PREFIX}/bin/nanoporeTK"

cat > "${PREFIX}/bin/nanoporeTK" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

BIN_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
NANOPORETK_ROOT="$(cd -- "${BIN_DIR}/../share/nanoporetk" && pwd -P)"

exec "${NANOPORETK_ROOT}/nanoporeTK" "$@"
EOF

chmod 0755 "${PREFIX}/bin/nanoporeTK"

echo "[INFO] nanoporeTK installation complete"