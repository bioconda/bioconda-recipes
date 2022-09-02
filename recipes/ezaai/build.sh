#!/bin/bash
EZ_AAI_JAR_NAME="EzAAI_v${PKG_VERSION}.jar"
EZ_AAI_BIN="${PREFIX}/bin/EzAAI"

# Copy the JAR to the resource directory
TARGET="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"
mkdir -p "${TARGET}"
cp "${EZ_AAI_JAR_NAME}" "${TARGET}"

# Alias the JAR in the bin directory
mkdir -p "${PREFIX}/bin"
echo '#!/usr/bin/env bash' > "${EZ_AAI_BIN}"
echo  "java -jar ${TARGET}/${EZ_AAI_JAR_NAME} \$@" >> "${EZ_AAI_BIN}"
chmod +x "${EZ_AAI_BIN}"
