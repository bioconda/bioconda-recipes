#!/bin/bash -euo

wget https://github.com/boostorg/boost/releases/download/boost-1.85.0/boost-1.85.0-cmake.tar.gz

mv boost-1.85.0-cmake.tar.gz vendor/boost-1.55-bamrc.tar.gz

mkdir -p "${PREFIX}/bin"

# Needed for building utils dependency
export INCLUDES="-I{PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -pthread -L${PREFIX}/lib"

mkdir -p build
pushd build
cmake -S .. -B . -DCMAKE_INSTALL_PREFIX="${PREFIX}" -Wno-dev -Wno-deprecated --no-warn-unused-cli
make CXX="${CXX} ${LDFLAGS}" CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include" -j "${CPU_COUNT}"

chmod 755 bin/bam-readcount
cp -f bin/bam-readcount "${PREFIX}/bin"
popd
