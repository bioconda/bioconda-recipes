#!/bin/bash

export M4="${BUILD_PREFIX}/bin/m4"
export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"

if [ "$(uname -s)" == Linux ]
      then
	  #libkj.a needs to link against librt on Linux
	  sed -i.bak "s/pthread/pthread -lrt/g" Makefile.in
	  rm -rf *.bak
fi

autoreconf -i
./configure  --prefix="${PREFIX}" CXX="${CXX}" CXXFLAGS="${CXXFLAGS} -O3 -std=c++14" CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include -std=c++14" LDFLAGS="${LDFLAGS} -L${PREFIX}/lib" --with-capnp="${PREFIX}" --with-gsl="${PREFIX}"
make -j"${CPU_COUNT}"
make install
