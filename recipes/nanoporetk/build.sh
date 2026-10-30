
#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="${PREFIX}/share/nanoporetk"

mkdir -p "${INSTALL_DIR}" "${PREFIX}/bin"

# Install the main executable.
install -m 0755 \
  "${SRC_DIR}/nanoporeTK" \
  "${INSTALL_DIR}/nanoporeTK"

# Install only directories required at runtime.
for dir in config helpers lib modules; do
  cp -R "${SRC_DIR}/${dir}" "${INSTALL_DIR}/"
done

# Preserve version information.
install -m 0644 \
  "${SRC_DIR}/VERSION" \
  "${INSTALL_DIR}/VERSION"

install -m 0644 \
  "${SRC_DIR}/RELEASE_DATE" \
  "${INSTALL_DIR}/RELEASE_DATE"

# Create a command wrapper on PATH.
cat > "${PREFIX}/bin/nanoporeTK" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

BIN_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
NANOPORETK_ROOT="$(cd -- "${BIN_DIR}/../share/nanoporetk" && pwd -P)"

exec "${NANOPORETK_ROOT}/nanoporeTK" "$@"
EOF

chmod 0755 "${PREFIX}/bin/nanoporeTK"
