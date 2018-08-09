#!/bin/bash

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

NCBI_OUTDIR=$SRC_DIR/ncbi-outdir

if [[ $OSTYPE == darwin* ]]; then
     export LDFLAGS="${LDFLAGS} -headerpad_max_install_names"
fi

#pushd ngs
#./configure \
#    --prefix=$PREFIX \
#    --build-prefix=$NCBI_OUTDIR
#make
#1popd

pushd ncbi-vdb
./configure \
    --prefix=$PREFIX \
    --build-prefix=$NCBI_OUTDIR \
    --debug
make
popd

pushd sra-tools
./configure \
    --prefix=$PREFIX \
    --build-prefix=$NCBI_OUTDIR \
    --with-ngs-sdk-prefix=$PREFIX \
    --debug
make
make install
popd
