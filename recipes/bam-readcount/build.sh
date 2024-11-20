#!/bin/bash -ex

wget https://github.com/boostorg/boost/releases/download/boost-1.86.0/boost-1.86.0-cmake.tar.gz

mv boost-1.86.0-cmake.tar.gz vendor/boost-1.55-bamrc.tar.gz

# Needed for building utils dependency
export INCLUDES="-I{PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -pthread -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include"

if [[ `uname` == Darwin ]]; then
	export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib"
	export CFLAGS="${CFLAGS} -Wno-unguarded-availability -Wno-deprecated-non-prototype"
	export CMAKE_EXTRA="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CMAKE_EXTRA=""
fi

cmake -S . -B build -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_C_COMPILER="${CC}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-DCMAKE_C_FLAGS="${CFLAGS}" \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	"${CMAKE_EXTRA}"

cmake --build build -j "${CPU_COUNT}" -v

install -d "$PREFIX/bin"
install -v -m 0755 bin/bam-readcount "$PREFIX/bin"
