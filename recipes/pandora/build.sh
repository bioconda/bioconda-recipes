#!/bin/bash
set -eux -o pipefail

# make compilation not be dependent on locale settings
export LC_ALL=C

# allows boost to find gcc/g++ toolset
BIN_DIR=$(realpath /opt/conda/conda-bld/pandora_*/_build_env/bin/)
cp "${BIN_DIR}/x86_64-conda-linux-gnu-gcc" "${BIN_DIR}/gcc"
cp "${BIN_DIR}/x86_64-conda-linux-gnu-g++" "${BIN_DIR}/g++"

# build pandora
mkdir -p build
cd build
cmake -DBIOCONDA=True \
      -DCMAKE_BUILD_TYPE=Release \
      -DHUNTER_JOBS_NUMBER=4 \
      -DCMAKE_INSTALL_PREFIX="$PREFIX" \
      ..
make -j4

# test
ctest

# install
make install
