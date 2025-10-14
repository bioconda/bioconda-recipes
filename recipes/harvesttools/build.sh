#!/bin/bash

mkdir -p "$PREFIX/bin"
#mkdir -p "google/protobuf/stubs"
if [[ $(uname) == 'Darwin' ]];then
   cp harvesttools $PREFIX/bin/
else
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
autoreconf -if
sed -i '2212s/-std=c++11//' configure
sed -i '1s/-std=c++11/-std=c++14 -g/' Makefile.in
sed -i '8s/-Wl,--wrap=memcpy//' Makefile.in
sed -i "53s/compile/compile -I@capnp@\/include/" Makefile.in
sed -i '210s/INT_MAX, //' src/harvest/HarvestIO.cpp
sed -i 's/ln -sf/cp -f/g' Makefile.in 
if [[ $(uname) == 'aarch64' ]];then
 	sed -i "1s/2.2.5/2.17/" src/harvest/memcpyLink.h
fi
./configure --prefix="${PREFIX}" \
	--with-protobuf="${BUILD_PREFIX}" \
	--with-capnp="${PREFIX}" \
	PROTOC="${BUILD_PREFIX}/bin/protoc" \
	CXX="${CXX}" \
	CXXFLAGS="${CXXFLAGS} -g" \
	CPPFLAGS="${CPPFLAGS}" \
	LDFLAGS="${LDFLAGS}"

make
make install
fi
