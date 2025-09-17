#!/bin/bash

mkdir -p ${PREFIX}/bin

export INCLUDES="-I${PREFIX}/include"
export CPLUS_INCLUDE_PATH="${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++14 -I${PREFIX}/include"

if [[ `uname` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
	export CXXFLAGS="${CXXFLAGS} -Wno-dev -Wno-deprecated-declarations -Wno-unused-command-line-argument"
else
	export CONFIG_ARGS=""
fi

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-DBOOST_ROOT="${PREFIX}" \
	"${CONFIG_ARGS}"
cmake --build build -j "${CPU_COUNT}"

chmod 0755 bin/*
mv bin/bayesTyper ${PREFIX}/bin
mv bin/bayesTyperTools ${PREFIX}/bin
