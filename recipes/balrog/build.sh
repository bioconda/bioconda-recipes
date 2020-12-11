#!/bin/bash

export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DBUILD_SHARED_LIBS=OFF ..
make -j${CPU_COUNT} ${VERBOSE_CM}
make install prefix=$PREFIX CXX=$CXX CC=$CC LDFLAGS="-L$PREFIX/lib"