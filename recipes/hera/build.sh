#!/bin/bash

mkdir -p $PREFIX/bin

export CFLAGS="-I$PREFIX/include -fgnu89-inline -O2 -D USE_JEMALLOC  -w -lrt -lz"
export LIBS="-pthread -lm ${PREFIX}/lib/libz.a -lm ${PREFIX}/lib/libjemalloc.a -lm ${PREFIX}/lib/libhdf5.a  -lm ${PREFIX}/lib/libhdf5_hl.a -ldl -lm ${PREFIX}/lib/libdivsufsort64.*"

./configure

if [ $UNAME == "Darwin" ]
then
  echo "Mac"
  make -f Makefile_mac
else
  echo "Linux"
 make -f Makefile_linux
fi
cp build/hera $PREFIX/bin
cp build/hera_build $PREFIX/bin
