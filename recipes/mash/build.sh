#!/bin/bash

export M4="${BUILD_PREFIX}/bin/m4"
export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
#libkj.a needs to link against librt
sed -i.bak "s/pthread/pthread -lrt/g" Makefile.in
rm -rf *.bak

autoreconf -i
./configure  --prefix="${PREFIX}" CXX="${CXX}" CXXFLAGS="${CXXFLAGS} -O3" CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include" LDFLAGS="${LDFLAGS} -L${PREFIX}/lib" --with-capnp="${PREFIX}" --with-gsl="${PREFIX}"
make -j"${CPU_COUNT}"
make install
