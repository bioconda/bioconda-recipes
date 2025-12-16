#!/bin/bash

# without these lines, -lz can not be found
export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export CPLUS_INCLUDE_PATH="${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 -L${PREFIX}/lib"

export M4="${BUILD_PREFIX}/bin/m4"

mkdir -p ${PREFIX}/bin

if [[ "$(uname -s)" == "Darwin" ]]; then
	export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib -headerpad_max_install_names"
fi

autoreconf -if
./configure --prefix="${PREFIX}" --with-gsl="${PREFIX}" \
	CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}" \
	CPPFLAGS="${CPPFLAGS}" --disable-option-checking

sed -i.bak 's|-std=c++11|-std=c++14|' Makefile
rm -rf *.bak

make -j"${CPU_COUNT}"
make install
