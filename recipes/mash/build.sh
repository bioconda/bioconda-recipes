#!/bin/bash

export M4="${BUILD_PREFIX}/bin/m4"

#libkj.a needs to link against librt
sed -i.bak "s/pthread/pthread -lrt/g" Makefile.in
rm -rf *.bak
autoreconf -if
./configure CXX="${CXX}" CXXFLAGS="${CXXFLAGS} -O3" \
	--with-capnp="${PREFIX}" --with-gsl="${PREFIX}" --prefix="${PREFIX}" \
	LDFLAGS="${LDFLAGS} -L${PREFIX}/lib" \
	CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
make
make install
