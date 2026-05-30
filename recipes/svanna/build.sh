#!/bin/bash
set -eu -o pipefail

# The distribution zip extracts to svanna-cli-${PKG_VERSION}/
SVANNA_DIR="svanna-cli-${PKG_VERSION}"

# Create target directories
mkdir -p "${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"
mkdir -p "${PREFIX}/bin"

# Copy the JAR with a consistent name and supporting files
cp "${SVANNA_DIR}/svanna-cli-${PKG_VERSION}.jar" "${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}/svanna-cli.jar"
cp -r "${SVANNA_DIR}/examples" "${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}/" 2>/dev/null || true

# Create wrapper script
cat > "${PREFIX}/bin/svanna-cli" <<EOF
#!/bin/bash
exec java -jar "\${CONDA_PREFIX}/share/${PKG_NAME}-${PKG_VERSION}/svanna-cli.jar" "\$@"
EOF

chmod +x "${PREFIX}/bin/svanna-cli"
