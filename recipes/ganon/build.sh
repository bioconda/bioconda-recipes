#!/bin/bash

# Install python packages
cd ${SRC_DIR}/ganon/
$PYTHON -m pip install . -vvv --no-deps --no-build-isolation --no-cache-dir

# Build and install cpp packages
mv ${SRC_DIR}/robin-hood-hashing ${SRC_DIR}/ganon/libs/
mkdir build_cpp && cd build_cpp
cmake -DCMAKE_BUILD_TYPE=Release -DVERBOSE_CONFIG=ON -DCONDA=ON -DCMAKE_INSTALL_PREFIX=${PREFIX} ..
make
make install

# Test cpp
ctest -VV .
# Test python
cd ${SRC_DIR}/ganon/
$PYTHON -m unittest discover -s tests/ganon/integration/ -v
