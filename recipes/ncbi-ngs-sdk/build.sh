#!/usr/bin/env bash

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

NCBI_OUTDIR=$SRC_DIR/ncbi-outdir

if [[ $OSTYPE == darwin* ]]; then
     export LDFLAGS="${LDFLAGS} -headerpad_max_install_names"
fi

ln -s ${GCC} $BUILD_PREFIX/bin/gcc
ln -s ${CC} $BUILD_PREFIX/bin/cc
ln -s ${CXX} $BUILD_PREFIX/bin/g++
ln -s ${AR} $BUILD_PREFIX/bin/ar
ln -s ${LD} $BUILD_PREFIX/bin/ld

export PATH=$BUILD_PREFIX/bin:$PATH

pushd ngs-sdk
./configure \
    --prefix=$PREFIX \
    --build-prefix=$NCBI_OUTDIR \
    --debug
make
make install
make test
popd
