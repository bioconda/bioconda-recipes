#!/bin/bash
set -eu -o pipefail

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib

export CFLAGS="${CFLAGS} -O3 -L${PREFIX}/lib -I${PREFIX}/include"

cmake -S . -B build \
	-DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}" \
	-DCMAKE_BUILD_TYPE=RELEASE \
	-DCMAKE_C_FLAGS="${CFLAGS}" \
	-DCONDA_BUILD=TRUE \
	-DLIBSTADEN_LDFLAGS="-L${PREFIX}/lib" \
	-DBoost_NO_BOOST_CMAKE=ON \
	-DCMAKE_OSX_DEPLOYMENT_TARGET=10.11 \
	-DBoost_NO_SYSTEM_PATHS=ON \
	-DNO_IPO=TRUE

cmake --build build/ --target install -v
