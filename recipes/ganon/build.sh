#!/bin/bash

# Install python packages
cd ${SRC_DIR}/ganon/
$PYTHON setup.py install --single-version-externally-managed --record=record.txt

# Build and install cpp packages
mv ${SRC_DIR}/robin-hood-hashing ${SRC_DIR}/ganon/libs/
mkdir build_cpp && cd build_cpp
cmake -DCMAKE_BUILD_TYPE=Release -DVERBOSE_CONFIG=ON -DCONDA=ON -DCMAKE_INSTALL_PREFIX=${PREFIX} ..
make
make install

# Tests cpp
ctest -VV . 

# Test python
cd ${SRC_DIR}/ganon/

genome_updater.sh -Z
curl --version

$PYTHON -m unittest discover -s tests/ganon/integration/ -v
#$PYTHON -m unittest discover -s tests/ganon/integration_online/ -v

cat tests/ganon/results/integration/build/test_og_arc_bac_vir.log
cat tests/ganon/results/integration/build/test_taxid.log
cat tests/ganon/results/integration/update/test_db_prefix.log
cat tests/ganon/results/integration/update/test_output_db_prefix.log
