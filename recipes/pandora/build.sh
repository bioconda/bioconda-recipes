#!/bin/bash
set -eux -o pipefail

# make compilation not be dependent on locale settings
export LC_ALL=C

# allows boost to find the correct build toolset in Linux
BIN_DIR=$(which x86_64-conda-linux-gnu-gcc)
BIN_DIR="$(dirname "${BIN_DIR}")"
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
make -j1  # Note: don't change this, or Bioconda Circle CI will error out with "OSError: [Errno 12] Cannot allocate memory"

# test
# ctest -VV -j1  # skipping tests to check if we can build the recipe

# install
make install
