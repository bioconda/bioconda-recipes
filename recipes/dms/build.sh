#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++14"

mkdir -p ${PREFIX}/bin

if [[ "$target_platform" == "linux-aarch64" ]]; then
	sed -i.bak '3s/-msse//g' Makefile	
fi

make CXX="${CXX} ${CPPFLAGS} ${CXXFLAGS} -fopenmp -DOMP ${LDFLAGS}" -j"${CPU_COUNT}"
#export DynamicMetaStorms=${PREFIX}/bin
install -v -m 0755 bin/* ${PREFIX}/bin

cp -rf databases ${PREFIX}
cp -rf example ${PREFIX}
