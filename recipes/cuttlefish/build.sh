#!/bin/bash

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -fcommon -I${PREFIX}/include"

if [[ `uname` == 'Darwin' ]]; then
	export MACOSX_DEPLOYMENT_TARGET=10.11
	export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	# It's dumb and absurd that the KMC build can't find the bzip2 header <bzlib.h>
	export C_INCLUDE_PATH="$PREFIX/include"
	export CPLUS_INCLUDE_PATH="$PREFIX/include"
	export CONFIG_ARGS=""
fi

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-DINSTANCE_COUNT=64 \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	"${CONFIG_ARGS}"
cmake --build build/ --target install -j "${CPU_COUNT}" -v
