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
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

cmake -S . -B build \
	-DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_BUILD_TYPE=Release \
	-DBUILD_SHARED_LIBS=ON \
	-DCMAKE_INSTALL_LIBDIR="${PREFIX}/lib" \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS} -Wno-return-type -Wno-unused-result -Wno-unused-but-set-variable" \
	-DHTSLIB_DIR="${PREFIX}/include/htslib" \
	"${CONFIG_ARGS}"

cd build

make CC="${CC}" -j"${CPU_COUNT}"
install -v -m 0755 libseqlib.* "${PREFIX}/lib"
