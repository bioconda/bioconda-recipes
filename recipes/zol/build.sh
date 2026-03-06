#!/bin/bash
set -xe

mkdir -p ${PREFIX}/bin

$PYTHON -m pip install . --no-build-isolation --no-deps --no-cache-dir -vvv

export LDFLAGS=
${CXX} -std=c++14 -Wl,-headerpad_max_install_names -o ${PREFIX}/bin/runRBH src/zol/orthologs/runRBH.cpp
${CXX} -std=c++14 -Wl,-headerpad_max_install_names -o ${PREFIX}/bin/splitDiamondResults src/zol/orthologs/splitDiamondResults.cpp
${CXX} -std=c++14 -Wl,-headerpad_max_install_names -o ${PREFIX}/bin/splitDiamondResultsForFai src/zol/splitDiamondResultsForFai.cpp

chmod +x ${PREFIX}/bin/runRBH
chmod +x ${PREFIX}/bin/splitDiamondResults
chmod +x ${PREFIX}/bin/splitDiamondResultsForFai

# setup gravis from a pinned Git commit to ensure reproducible builds
# We point pip directly to the git repository 
curl -sL https://github.com/raufs/gravis/archive/refs/tags/v0.1.1.tar.gz | sha256sum | grep -q "d8a8b09a23522ab746eea740adc05f22cb6a1d5190c1b64ee4f304e62b37268b  -" && echo "Matching SHA256 for gravis" || echo "Mismatch SHA256 for gravis" && exit 1
$PYTHON -m pip install https://github.com/raufs/gravis/archive/refs/tags/v1.0.0.tar.gz --upgrade --no-deps --no-build-isolation -vvv

# create folder for database download
ZOL_DATA_PATH="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}/db"
ZOL_EXEC_PATH="${PREFIX}/bin"
mkdir -p "${ZOL_DATA_PATH}"
echo 'Default conda space for downloading annotation databases.\n' > ${ZOL_DATA_PATH}/README.txt

# set ZOL_DATA_PATH and ZOL_EXEC_PATH variables on env activation
mkdir -p ${PREFIX}/etc/conda/activate.d ${PREFIX}/etc/conda/deactivate.d
cat <<EOF >> ${PREFIX}/etc/conda/activate.d/zol.sh
export ZOL_DATA_PATH=${ZOL_DATA_PATH}
export ZOL_EXEC_PATH=${ZOL_EXEC_PATH}
EOF

cat <<EOF >> ${PREFIX}/etc/conda/deactivate.d/zol.sh
unset ZOL_DATA_PATH
unset ZOL_EXEC_PATH
EOF

echo "Users of zol, please note, we use an unofficial fork of gravis (v1.0.0; https://github.com/raufs/gravis), not the original/official gravis (https://github.com/robert-haas/gravis)"
