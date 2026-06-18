#!/bin/bash
set -xe
mkdir -p ${PREFIX}/bin

# setup gravis from forked version
# pip installation configuration based on conda-forge recipe: https://github.com/conda-forge/gravis-feedstock/blob/main/recipe/meta.yaml
cd gravis_fork_folder/
$PYTHON -m pip install . -vv

cd ../zol_folder/
$PYTHON -m pip install . --no-build-isolation --no-deps --no-cache-dir -vvv

export LDFLAGS=
${CXX} -std=c++14 -Wl,-headerpad_max_install_names -o ${PREFIX}/bin/runRBH src/zol/orthologs/runRBH.cpp
${CXX} -std=c++14 -Wl,-headerpad_max_install_names -o ${PREFIX}/bin/splitDiamondResults src/zol/orthologs/splitDiamondResults.cpp
${CXX} -std=c++14 -Wl,-headerpad_max_install_names -o ${PREFIX}/bin/splitDiamondResultsForFai src/zol/splitDiamondResultsForFai.cpp

chmod +x ${PREFIX}/bin/runRBH
chmod +x ${PREFIX}/bin/splitDiamondResults
chmod +x ${PREFIX}/bin/splitDiamondResultsForFai

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

echo "Users of zol, please note, we use an unofficial fork of gravis (v0.1.1; https://github.com/raufs/gravis), not the original/official gravis (https://github.com/robert-haas/gravis)"
