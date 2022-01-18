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
$PYTHON -m unittest discover -s tests/ganon/unit/ -v
$PYTHON -m unittest discover -s tests/ganon/integration/ -v
#$PYTHON -m unittest discover -s tests/ganon/integration_online/ -v
