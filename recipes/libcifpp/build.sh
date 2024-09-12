#!/bin/bash

export INCLUDES="-I{PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include"

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_CXX_COMPILER="${CXX}" \
        -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-DBUILD_TESTING=OFF -DCIFPP_DOWNLOAD_CCD=OFF \
	-DCIFPP_INSTALL_UPDATE_SCRIPT=OFF

cmake --build build/ --target install -j "${CPU_COUNT}" -v
