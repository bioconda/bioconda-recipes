#!/bin/bash
set -eu -o pipefail

# The project's Makefiles don't use {CPP,C,CXX,LD}FLAGS everywhere.
# We can try to patch all of those or export the following *_PATH variables.
export C_INCLUDE_PATH="${PREFIX}/include"
export CPLUS_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export ZLIB_PATH="${PREFIX}/lib/"

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $outdir/scripts
mkdir -p $PREFIX/bin

pushd src/utils/sqlite3
sed -i.bak "s#@gcc#${CC}#g" Makefile
popd

make \
    CC="${CC}" \
    CXX="${CXX}" \
    CPPFLAGS="${CPPFLAGS}" \
    CFLAGS="${CFLAGS}" \
    CXXFLAGS="${CXXFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    ZLIB_PATH="${PREFIX/lib}"

cp bin/* $PREFIX/bin
cp $RECIPE_DIR/lumpyexpress.config $PREFIX/bin/lumpyexpress.config
cp scripts/lumpyexpress $PREFIX/bin
cp scripts/cnvanator_to_bedpes.py $PREFIX/bin

cp scripts/*.py $outdir/scripts
cp scripts/*.sh $outdir/scripts
cp scripts/*.pl $outdir/scripts
cp scripts/extractSplitReads* $outdir/scripts
cp scripts/vcf* $outdir/scripts

ln -s $outdir/scripts/extractSplitReads_BwaMem $PREFIX/bin

chmod +x $PREFIX/bin/extractSplitReads_BwaMem
