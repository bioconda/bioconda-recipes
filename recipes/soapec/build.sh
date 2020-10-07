#!/bin/sh
set -x -e

mkdir -p $PREFIX/bin

export CPP_INCLUDE_PATH="${PREFIX}/include"
export CXX_INCLUDE_PATH="${PREFIX}/include"
export CPLUS_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
for f in src/*/Makefile;
do
    sed -i.bak 's/-static//' $f
done
for f in */*/*.cpp;
do
    sed -i.bam "s/^FORCE_INLINE/inline FORCE_INLINE/g" $f;
done

make
PREFIX=$PREFIX/bin make install
