#!/bin/bash

set -euo pipefail

mkdir -p ${PREFIX}/lib
cp -f "${SRC_DIR}/cluster_one-${PKG_VERSION}.jar" "${PREFIX}/lib/cluster_one-v${PKG_VERSION}.jar"

mkdir -p ${PREFIX}/bin
echo '#!/bin/bash' > ${PREFIX}/bin/clusterone
echo 'java -jar "'$PREFIX'/lib/cluster_one-v'$PKG_VERSION'.jar" "$@"' >> $PREFIX/bin/clusterone
chmod +x "${PREFIX}/bin/clusterone"