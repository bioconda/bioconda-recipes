#!/bin/sh

cd $SRC_DIR/src
mkdir -p $PREFIX/bin

binaries="\
selscan \
norm \
"

# for zlib
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

make

for i in $binaries; do cp $SRC_DIR/src/$i $PREFIX/bin/ && chmod +x $PREFIX/bin/$i; done
