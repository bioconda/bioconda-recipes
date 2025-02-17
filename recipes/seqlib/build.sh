#!/bin/bash -e

mkdir build

if [[ "$(uname)" == "Darwin" ]]; then
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CONFIG_ARGS=""
fi

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include -O3"

cmake -S . -B build \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_BUILD_TYPE=Release \
	-DBUILD_SHARED_LIBS=ON \
	-DCMAKE_INSTALL_LIBDIR="${PREFIX}/lib" \
	-DCMAKE_C_COMPILER="${CC}" \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS} -Wno-return-type" \
	-DHTSLIB_DIR="${PREFIX}/include/htslib" \
	"${CONFIG_ARGS}"

cd build

make -j"${CPU_COUNT}"
install -v -m 0755 libseqlib.* "${PREFIX}/lib"
