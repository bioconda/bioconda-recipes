#!/bin/bash

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include -Wno-deprecated-declarations -Wno-unused-but-set-variable -Wno-ignored-optimization-argument"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -fopenmp"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CPATH="${PREFIX}/include"
export CPP_INCLUDE_PATH="${PREFIX}/include"

if [[ `uname` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

rm -rf build

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_CXX_COMPILER="${CXX}" -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-DCMAKE_C_COMPILER="${CC}" -DCMAKE_C_FLAGS="${CFLAGS}" \
	-DSTATIC_BUILD=ON -DSANITIZER=ON -DTSAN=ON "${CONFIG_ARGS}"
cmake --build build --target install -j "${CPU_COUNT}"
