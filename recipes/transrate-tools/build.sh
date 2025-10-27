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

case $(uname -m) in
    aarch64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
	;;
    arm64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
	;;
    x86_64)
	export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
	;;
esac

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

cmake --build build -j 1

install -v -m 0755 build/src/bam-read "$PREFIX/bin"
