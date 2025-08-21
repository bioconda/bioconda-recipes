#!/bin/bash

set -xe

export M4="$BUILD_PREFIX/bin/m4"

# add Configuration and example files to opt
falco=$PREFIX/opt/falco
mkdir -p $falco
cp -rf ./* $falco

#to fix problems with htslib
export C_INCLUDE_PATH=$C_INCLUDE_PATH:${PREFIX}/include
export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:${PREFIX}/include
export LIBRARY_PATH=$LIBRARY_PATH:${PREFIX}/lib
export LD_LIBRARY_PATH=$LIBRARY_PATH:${PREFIX}/lib

export INCLUDES="-I{PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -I{PREFIX}/include"

cd $falco
autoreconf -if
./configure --prefix=$falco --enable-hts CXX="${CXX}" CXXFLAGS="${CXXFLAGS}"
make -j ${CPU_COUNT}
make install
for i in $(ls -1 | grep -v Configuration | grep -v bin);
do
  rm -rf ${i};
done
mv $falco/bin/falco $PREFIX/bin
rm -rf bin
