#!/bin/bash
set -euo pipefail

# build.sh — installs a pre-built Java .jar and executable wrapper to conda prefix
# --> .jar     $PREFIX/share/scriptmanager-0.15/scriptmanager-v0.15.jar
# --> wrapper  $PREFIX/bin/scriptmanager

SHARE_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}"
mkdir -p "${SHARE_DIR}"
mkdir -p "${PREFIX}/bin"

# Copy .jar to globally share directory
cp "${SRC_DIR}/${PKG_NAME}-v${PKG_VERSION}.jar" "${SHARE_DIR}/"

# Create wrapper script to execute the .jar
cat > "${PREFIX}/bin/${PKG_NAME}" <<EOF
#!/usr/bin/env bash
# Conda wrapper for ${PKG_NAME} ${PKG_VERSION}
#
# Default JVM memory: 2 GB.  Override with the environment variable
# JAVA_OPTS (e.g.:  export JAVA_OPTS="-Xmx8g")

set -euo pipefail

JAVA_OPTS=\${JAVA_OPTS:-"-Xmx2g"}

exec java \${JAVA_OPTS} \\
    -jar "\${CONDA_PREFIX}/share/${PKG_NAME}-${PKG_VERSION}/${PKG_NAME}-v${PKG_VERSION}.jar" \\
    "\$@"
EOF

# Make script executable
chmod +x "${PREFIX}/bin/${PKG_NAME}"
