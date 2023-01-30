#!/bin/bash

mkdir build
cd build

#mkdir -p ../external/include
#cp ${PREFIX}/include/bzlib.h ../external/include/
#cp ${PREFIX}/include/zlib.h ../external/include/
#cp ${PREFIX}/include/bzlib.h ../external/include/
#cp ${PREFIX}/include/zlib.h ../external/include/

# hack! because bzip2 is broken.
cmake \
    -DCMAKE_C_COMPILER="${CC} -I${PREFIX}/include" \
    -DCMAKE_CXX_COMPILER="${CXX} -I${PREFIX}/include" \
    -DINSTANCE_COUNT=64 \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCONDA_BUILD=ON \
    ..
make install
