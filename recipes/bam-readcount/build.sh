#!/bin/bash -euo

# Needed for building utils dependency
export INCLUDES="-I{PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -pthread -L${PREFIX}/lib"

mkdir -p "${PREFIX}/bin"

mkdir build
pushd build
cmake ..
make CXX="${CXX} ${LDFLAGS}" CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include"

chmod 755 bin/bam-readcount
cp -f bin/bam-readcount "${PREFIX}/bin"
popd
