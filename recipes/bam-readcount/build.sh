#!/bin/bash -ex

wget https://github.com/boostorg/boost/releases/download/boost-1.85.0/boost-1.85.0-cmake.tar.gz

mv boost-1.85.0-cmake.tar.gz vendor/boost-1.55-bamrc.tar.gz

mkdir -p "${PREFIX}/bin"

# Needed for building utils dependency
export INCLUDES="-I{PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -pthread -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include"

if [[ `uname` == Darwin ]]; then
	export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib"
	export CFLAGS="${CFLAGS} -Wno-unguarded-availability -Wdeprecated-non-prototype"
	export CMAKE_EXTRA="-DCMAKE_FIND_FRAMEWORK=NEVER -DCMAKE_FIND_APPBUNDLE=NEVER"
else
	export CMAKE_EXTRA=""
fi

mkdir -p build
pushd build
cmake -S .. -B . -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_C_COMPILER="${CC}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-DCMAKE_C_FLAGS="${CFLAGS}" \
	-Wno-dev -Wno-deprecated --no-warn-unused-cli \
	${CMAKE_EXTRA}

make clean
make CXX="${CXX} ${LDFLAGS}" CC="${CC}" CXXFLAGS="${CXXFLAGS}" CFLAGS="${CFLAGS}"

chmod 755 bin/bam-readcount
cp -f bin/bam-readcount "${PREFIX}/bin"
popd
