#!/bin/bash

mkdir build
cd build

mkdir -p ../external/include
cp ${PREFIX}/include/bzlib.h ../external/include/
cp ${PREFIX}/include/zlib.h ../external/include/
cp ${PREFIX}/include/bzlib.h ../external/include/
cp ${PREFIX}/include/zlib.h ../external/include/

# hack! because bzip2 is broken.
cmake \
    -DINSTANCE_COUNT=64 \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCONDA_BUILD=ON \
    ..

mkdir -p ../external/KMC-3.2.1/kmc_core/
cp ${PREFIX}/include/bzlib.h ../external/KMC-3.2.1/kmc_core/
cp ${PREFIX}/include/zlib.h ../external/KMC-3.2.1/kmc_core/
cp ${PREFIX}/include/bzlib.h ../external/KMC-3.2.1/kmc_core/
cp ${PREFIX}/include/zlib.h ../external/KMC-3.2.1/kmc_core/

make install
