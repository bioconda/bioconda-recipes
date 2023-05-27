#!/bin/bash
set -ex

export CPLUS_INCLUDE_PATH="${PREFIX}/include"
export LIBPATH="${PREFIX}/lib"
export LDFLAGS="-L${PREFIX}/lib"
export CXXFLAGS="-O3 -D_FILE_OFFSET_BITS=64 ${LDFLAGS}"

cmake -S . -B build -DCMAKE_INSTALL_PREFIX=${PREFIX} -DBUILD_SHARED_LIBS=ON
cmake --build build --target install --config Release -v
