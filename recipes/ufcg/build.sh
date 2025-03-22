#!/bin/bash

set -x -e

UFCG_JAR="ufcg.jar"
UFCG_LIC="LICENSE.md"
UFCG_BIN="${PREFIX}/bin/ufcg"

# Copy JAR to the resource directory
TARGET="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"
mkdir -p "${TARGET}"
cp "${UFCG_JAR}" "${TARGET}"
cp "${UFCG_LIC}" "${TARGET}"

# Alias JAR
mkdir -p "${PREFIX}/bin"
echo "#!/bin/sh" > "${UFCG_BIN}"
echo "java -jar ${TARGET}/${UFCG_JAR} \"\$@\"" >> "${UFCG_BIN}"
chmod +x "${UFCG_BIN}"

