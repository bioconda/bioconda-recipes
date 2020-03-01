#!/bin/bash

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

NCBI_OUTDIR=$SRC_DIR/ncbi-outdir

if [[ $OSTYPE == darwin* ]]; then
     export LDFLAGS="${LDFLAGS} -headerpad_max_install_names"
fi

export PATH=$BUILD_PREFIX/bin:$PATH

pushd ncbi-vdb
./configure \
    --prefix=$PREFIX \
    --build-prefix=$NCBI_OUTDIR \
    --with-ngs-sdk-prefix=$PREFIX \
    CXX=$CXX
make -j${CPU_COUNT}
popd

pushd sra-tools

pushd tools/driver-tool/utf8proc
make -j${CPU_COUNT}
popd

./configure \
    --prefix=$PREFIX \
    --build-prefix=$NCBI_OUTDIR \
    --with-ngs-sdk-prefix=$PREFIX \
    --with-ncbi-vdb-build=$NCBI_OUTDIR \
    CXX=$CXX
make -j${CPU_COUNT}
make install
popd

# Strip package version from binary names
cd $PREFIX/bin
ln -s fastq-dump-orig.$PKG_VERSION fastq-dump-orig
ln -s fasterq-dump-orig.$PKG_VERSION fasterq-dump-orig
ln -s prefetch-orig.$PKG_VERSION prefetch-orig
ln -s sam-dump-orig.$PKG_VERSION sam-dump-orig
ln -s srapath-orig.$PKG_VERSION srapath-orig
ln -s sra-pileup-orig.$PKG_VERSION sra-pileup-orig
