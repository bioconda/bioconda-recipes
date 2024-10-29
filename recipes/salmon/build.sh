#!/bin/bash
set -eu -o pipefail

export CFLAGS="${CFLAGS} -O3 -L${PREFIX}/lib"

if [[ `uname` == "Darwin" ]]; then
	export CFLAGS="${CFLAGS} -Wunused-command-line-argument -Wunused-parameter"
	export CONFIG_ARGS="-DCMAKE_OSX_DEPLOYMENT_TARGET=10.11 -DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

cmake -S . -B build \
	-DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}" \
	-DCMAKE_BUILD_TYPE=RELEASE \
	-DCMAKE_C_COMPILER="${CC}" \
	-DCMAKE_C_FLAGS="${CFLAGS}" \
	-DCONDA_BUILD=TRUE \
	-DLIBSTADEN_LDFLAGS="-L${PREFIX}/lib" \
	-DBOOST_ROOT="${PREFIX}" \
	-DCEREAL_INCLUDE_DIR="${PREFIX}/include" \
	-DLIB_GFF_INCLUDE_DIR="${PREFIX}/include" \
	-DNO_IPO=TRUE \
 	-DSTADEN_INCLUDE_DIR="${PREFIX}/include" \
  	-DSTADEN_VERSION="1.15.0" \
   	-DSTADEN_LIBRARY="${PREFIX}/lib/libstaden-read.a" \
	"${CONFIG_ARGS}"

cmake --build build/ --target install -v
