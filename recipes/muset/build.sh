#!/bin/bash
set -e
set -x

mkdir -p ${PREFIX}/bin

mkdir build-conda
cd build-conda

# Explicitly set CMAKE_INSTALL_PREFIX
cmake .. \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCONDA_BUILD=ON \
  -DCMAKE_BUILD_TYPE=Release

make -j${CPU_COUNT}  # Use conda's CPU_COUNT for parallel build
cd ..

# Copy binaries (though CMake might handle this with INSTALL_PREFIX)
cp ./bin/kmat_tools ${PREFIX}/bin
cp ./bin/muset ${PREFIX}/bin
cp ./bin/muset_pa ${PREFIX}/bin