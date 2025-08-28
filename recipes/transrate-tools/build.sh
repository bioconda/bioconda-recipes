#!/bin/bash
set -ef -o pipefail

mkdir -p "$PREFIX/bin"

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"

rm -rf bamtools
mkdir -p bamtools/include

ln -sf $PREFIX/lib bamtools/
ln -sf $PREFIX/include/bamtools/api bamtools/include/
ln -sf $PREFIX/include/bamtools/shared bamtools/include/

if [[ "$(uname -s)" == "Linux" ]]; then
	sed -i.bak 's|ZLIB REQUIRED STATIC|ZLIB REQUIRED|' CMakeLists.txt
	rm -rf *.bak
	export CONFIG_ARGS=""
else
	export CONFIG_ARGS="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
fi

cmake -S . -B build -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CONFIG_ARGS}"

cmake --build build --clean-first -j "${CPU_COUNT}"

install -v -m 0755 build/src/bam-read "$PREFIX/bin"
