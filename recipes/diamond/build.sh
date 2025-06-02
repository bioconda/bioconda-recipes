#!/bin/bash

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

if [[ `uname` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

sed -i.bak 's|VERSION 2.6|VERSION 3.5|' CMakeLists.txt
rm -rf *.bak

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include" \
	-DWITH_ZSTD=ON \
	-DZSTD_LIBRARY="${PREFIX}/lib/libzstd.a" \
	-DZSTD_INCLUDE_DIR="${PREFIX}/include" \
	-DBLAST_INCLUDE_DIR="${PREFIX}/include"
	-DBLAST_LIBRARY_DIR="${PREFIX}/lib/ncbi-blast+" \
	-DCMAKE_OSX_DEPLOYMENT_TARGET="" \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"

cmake --build build --clean-first --target install -j "${CPU_COUNT}"
