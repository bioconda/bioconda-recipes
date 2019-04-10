#!/bin/bash

set -ef -o pipefail

#export CPPFLAGS="$CPPFLAGS -I${PREFIX}/include -I${PREFIX}/include/bamtools"

#export C_INCLUDE_PATH="${PREFIX}/include:${PREFIX}/include/bamtools"
#export CPLUS_INCLUDE_PATH="${PREFIX}/include:${PREFIX}/include/bamtools"
#export CXXFLAGS="-I${PREFIX}/include -I${PREFIX}/include/bamtools"
#export CXX_FLAGS="-I${PREFIX}/include -I${PREFIX}/include/bamtools"
#export CMAKE_CXX_FLAGS="-I${PREFIX}/include -I${PREFIX}/include/bamtools"
#
#export LDFLAGS="$LDFLAGS -L${PREFIX}/lib"
#export LD_FLAGS="-L${PREFIX}/lib"
#export CMAKE_LD_FLAGS="-L${PREFIX}/lib"
#export CMAKE_LDFLAGS="-L${PREFIX}/lib"

rm -rf bamtools
mkdir -p bamtools
ln -s $PREFIX/lib bamtools/
ln -s $PREFIX/include bamtools/
mkdir -p build
pushd build

mkdir -p $PREFIX/bin

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_CXX_COMPILER=${CXX} ${SRC_DIR}
make
cp src/bam-read $PREFIX/bin/
popd
