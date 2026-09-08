#!/bin/bash
set -eu -o pipefail

SHARE_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"

mkdir -p "${SHARE_DIR}"
mkdir -p "${PREFIX}/bin"

cp "svanna-cli-${PKG_VERSION}.jar" "${SHARE_DIR}/svanna-cli.jar"
cp -r examples "${SHARE_DIR}/" 2>/dev/null || true

cat > "${SHARE_DIR}/svanna-cli" <<EOF
#!/bin/bash
exec java -jar "\${CONDA_PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}/svanna-cli.jar" "\$@"
EOF

chmod +x "${SHARE_DIR}/svanna-cli"
ln -sf "${SHARE_DIR}/svanna-cli" "${PREFIX}/bin/svanna-cli"
