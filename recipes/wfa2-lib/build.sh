#!/bin/bash
set -ex

export INCLUDES="-I${PREFIX}/include -I${BUILD_PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -D_FILE_OFFSET_BITS=64 ${LDFLAGS}"

cmake -S . -B build -DCMAKE_INSTALL_PREFIX=${PREFIX} -DBUILD_SHARED_LIBS=ON
cmake --build build --target install --config Release -v
