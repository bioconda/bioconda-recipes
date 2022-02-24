#!/bin/bash
set -eu -o pipefail

cd ./travis/build/broadinstitute/rnaseqc
export CFLAGS="${CFLAGS} -fcommon"

pushd SeqLib/bwa
sed -i.bak '/^DFLAGS=/s/$/ $(LDFLAGS)/' Makefile
make CC="$CC" CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS"
popd

pushd SeqLib/fermi-lite
make CC="$CC" CFLAGS="$CFLAGS $LDFLAGS"
popd

pushd SeqLib/htslib
make CC="$CC" CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS"
popd

make \
    CC="$CXX" \
    CPPFLAGS="-I$PREFIX/include -fcommon" \
    SeqLib/lib/libseqlib.a

make \
    CC="$CXX -fcommon" \
    INCLUDE_DIRS="-I$PREFIX/include -ISeqLib -ISeqLib/htslib" \
    LIBRARY_PATHS="-L$PREFIX/lib -Wl,-rpath $PREFIX/lib"

mkdir -p $PREFIX/bin
cp rnaseqc $PREFIX/bin

