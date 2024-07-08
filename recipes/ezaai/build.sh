#!/bin/bash
EZ_AAI_JAR_NAME="EzAAI.jar"
EZ_AAI_LICENSE="LICENSE.md"

EZ_AAI_BIN="${PREFIX}/bin/ezaai"
EZ_AAI_BIN_ALT="${PREFIX}/bin/EzAAI"

# Copy the JAR to the resource directory
TARGET="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"
mkdir -p "${TARGET}"
cp "${EZ_AAI_JAR_NAME}" "${TARGET}"
cp "${EZ_AAI_LICENSE}" "${TARGET}"

# Alias the JAR in the bin directory
mkdir -p "${PREFIX}/bin"
cat << EOF > "${EZ_AAI_BIN}"
#!/bin/sh
exec java -jar "${TARGET}/${EZ_AAI_JAR_NAME}" "\${@}"
EOF
chmod +x "${EZ_AAI_BIN}"
cp "${EZ_AAI_BIN}" "${EZ_AAI_BIN_ALT}"
