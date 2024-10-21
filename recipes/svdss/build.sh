#!/bin/bash

mkdir -p ${PREFIX}/bin

if [[ `uname` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

cmake -S. -B build -DCMAKE_BUILD_TYPE=Release \
	-DCONDAPREFIX="${PREFIX}" -DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include" \
	"${CONFIG_ARGS}"
cmake --build build -j "${CPU_COUNT}" -v

cd build
chmod 0755 SVDSS
cp -f SVDSS ${PREFIX}/bin
