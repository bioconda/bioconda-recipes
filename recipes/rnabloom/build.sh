#!/bin/bash

set -euo pipefail

mkdir -p ${PREFIX}/lib
cp -f "${SRC_DIR}/RNA-Bloom.jar" "${PREFIX}/lib/rnabloom-v${PKG_VERSION}.jar"

mkdir -p ${PREFIX}/bin
echo '#!/bin/bash' > ${PREFIX}/bin/rnabloom
echo 'java -jar "'$PREFIX'/lib/rnabloom-v'$PKG_VERSION'.jar" "$@"' >> $PREFIX/bin/rnabloom
chmod +x "${PREFIX}/bin/rnabloom"