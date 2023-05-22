#!/bin/bash

#$PYTHON setup.py install --single-version-externally-managed --record=record.txt
$PYTHON -m pip install . --ignore-installed --no-deps -vv

mkdir -p ${PREFIX}/bin

# (re)-compile RBH/InParanoid-esque programs written in C++
${CXX} -std=c++11 -o zol/orthologs/runRBH zol/orthologs/runRBH.cpp
${CXX} -std=c++11 -o zol/orthologs/splitDiamondResults zol/orthologs/splitDiamondResults.cpp
${CXX} -std=c++11 -o zol/splitDiamondResultsForFai zol/splitDiamondResultsForFai.cpp

cp zol/orthologs/runRBH ${PREFIX}/bin/
cp zol/orthologs/splitDiamondResults ${PREFIX}/bin/
cp zol/splitDiamondResultsForFai ${PREFIX}/bin/
cp zol/clusterHeatmap.R ${PREFIX}/bin/
cp zol/plotSegments.R ${PREFIX}/bin/

chmod +x ${PREFIX}/bin/runRBH
chmod +x ${PREFIX}/bin/splitDiamondResults
chmod +x ${PREFIX}/bin/splitDiamondResultsForFai

# create folder for database download
ZOL_DATA_PATH=${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}/db/
ZOL_EXEC_PATH=${PREFIX}/bin/
mkdir -p ${ZOL_DATA_PATH}
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
