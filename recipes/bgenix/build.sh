#!/bin/bash

export LD_LIBRARY_PATH=$PREFIX/lib:$LD_LIBRARY_PATH

sed -i 's/std::ios::streampos/std::streampos/g' src/View.cpp

./waf configure build install \
      --prefix=${PREFIX} \
      --bindir=${PREFIX}/bin \
      --libdir=${PREFIX}/lib \
      --jobs=${CPU_COUNT} \
      CFLAGS="${CFLAGS} -I${PREFIX}/include -I${PREFIX}/include/boost" \
      LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
