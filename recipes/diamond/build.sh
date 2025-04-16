#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

if [[ `uname` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

cmake -S. -B build -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS} -O3" \
	-DWITH_ZSTD=ON -DSTATIC_LIBGCC=ON -DSTATIC_LIBSTDC++=ON \
	-DZSTD_LIBRARY="${PREFIX}/lib/libzstd.a" \
	-DZSTD_INCLUDE_DIR="${PREFIX}/include" \
	-DBLAST_INCLUDE_DIR="${PREFIX}/include/ncbi" \
	-DBLAST_LIBRARY_DIR="${PREFIX}/lib/ncbi-blast+" \
	-DCMAKE_OSX_DEPLOYMENT_TARGET="" \
	"${CONFIG_ARGS}"

cmake --build build --target install
