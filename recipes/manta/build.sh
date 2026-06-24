#!/bin/bash
set -eu
set -x

mkdir build ; cd build
BOOST_ROOT=${PREFIX} ../configure --prefix=${PREFIX} --verbose


export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

make PREFIX="${PREFIX}" CXX="${CXX}" VERBOSE=1 \
  CXXFLAGS="${CXXFLAGS} -O3 -std=c++14" \
  INCLUDE_DIRS="$PREFIX/include" \
  LIBRARY_DIRS="$PREFIX/lib" -j"${CPU_COUNT}"
make install

ln -s $PREFIX/libexec/convertInversion.py $PREFIX/bin
ln -s $PREFIX/libexec/denovo_scoring.py $PREFIX/bin
