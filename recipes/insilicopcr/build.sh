#!/usr/bin/env bash
set -euo pipefail

SHARE="${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"
TARGET="${PREFIX}/share/${SHARE}"
mkdir -p "${TARGET}" "${PREFIX}/bin"
cp -R insilicoPCR.jar lib run-insilicoPCR.sh VERSIONS.txt "${TARGET}/"
chmod +x "${TARGET}/run-insilicoPCR.sh"

# The environment's Java, BLAST+ and BBTools, even when it is not activated (a full path, a workflow manager):
# insilicoPCR runs the blastn, makeblastdb and bbduk.sh it finds first on PATH.
cat > "${PREFIX}/bin/insilicoPCR" <<EOF
#!/usr/bin/env bash
BIN="\$(cd "\$(dirname "\$(readlink -f "\${BASH_SOURCE[0]}")")" && pwd)"
export PATH="\${BIN}:\${PATH}"
export JAVA_HOME="\$(dirname "\${BIN}")/lib/jvm"
exec "\$(dirname "\${BIN}")/share/${SHARE}/run-insilicoPCR.sh" "\$@"
EOF
chmod +x "${PREFIX}/bin/insilicoPCR"
ln -s insilicoPCR "${PREFIX}/bin/insilicopcr"
