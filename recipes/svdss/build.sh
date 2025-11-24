#!/bin/bash

mkdir -p ${PREFIX}/bin
export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"

if [[ `uname` == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
	sed -i.bak 's|libhts.so|libhts.dylib|' CMakeLists.txt
	sed -i.bak 's|libdeflate.so|libdeflate.dylib|' CMakeLists.txt
	sed -i.bak 's|sed -i|sed -i.bak|' CMakeLists.txt
	rm -rf *.bak
else
	export CONFIG_ARGS=""
fi

cmake -S. -B build -DCMAKE_BUILD_TYPE=Release \
	-DCONDAPREFIX="${PREFIX}" -DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" -DCMAKE_C_COMPILER="${CC}" \
	-DCMAKE_C_FLAGS="${CFLAGS}" \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"
cmake --build build -j "${CPU_COUNT}"

install -v -m 0755 SVDSS ${PREFIX}/bin
install -v -m 0755 run_svdss ${PREFIX}/bin
