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
# We point pip directly to the git repository and a specific commit SHA
$PYTHON -m pip install git+https://github.com/raufs/gravis.git@4f3c2d5e9b7a1c6d8e0f1234567890abcdef1234 --upgrade --no-deps --no-build-isolation -vvv

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
