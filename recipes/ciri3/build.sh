#!/usr/bin/env bash
set -euo pipefail

target="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"
mkdir -p "${PREFIX}/bin" "${target}/scripts"

# All classes in this upstream JAR target Java 8 (class-file version 52).
install -m 644 CIRI3_Java_1.8.0.jar "${target}/CIRI3.jar"
install -m 644 scripts/*.R "${target}/scripts/"

cat > "${target}/ciri3" <<EOF
#!/usr/bin/env bash
exec java -jar "${target}/CIRI3.jar" "\$@"
EOF
chmod 755 "${target}/ciri3"
ln -s "../share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}/ciri3" "${PREFIX}/bin/ciri3"

# CIRI3 resolves this helper relative to its JAR. Do not ship the bundled ELF.
cat > "${target}/scripts/rMATSexe" <<EOF
#!/usr/bin/env bash
exec "${PREFIX}/rMATS/rMATS_C/rMATSexe" "\$@"
EOF
chmod 755 "${target}/scripts/rMATSexe"
