#!/bin/bash

set -xe

# Link installed genome_updater.sh (dependency) into ganon's submodule dir
# to properly install script with pip
ln -s "$(command -v genome_updater.sh)" libs/genome_updater/genome_updater.sh
${PYTHON} -m pip install . -vvv --no-deps --no-build-isolation --no-cache-dir

# Build and install cpp packages
cmake -S . \
      -B build_cpp \
      -DCMAKE_BUILD_TYPE=Release \
      -DVERBOSE_CONFIG=ON \
      -DCONDA=ON \
      -DCMAKE_INSTALL_PREFIX="${PREFIX}"

make -C build_cpp -j "${CPU_COUNT}"
make -C build_cpp install

# Test cpp
ctest --test-dir build_cpp \
      --output-on-failure \
      --no-tests=error \
      --parallel "${CPU_COUNT}"

# Test python
${PYTHON} -m unittest discover -s tests/ganon/integration/ -v
