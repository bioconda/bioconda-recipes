#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p ${PREFIX}/bin

if [[ "$target_platform" == "linux-aarch64" || "$target_platform" == "osx-arm64" ]]; then
	sed -i.bak 's|-msse||' Makefile
	rm -rf *.bak
fi

make CXX="${CXX} ${CPPFLAGS} ${CXXFLAGS} -fopenmp -DOMP ${LDFLAGS}" -j"${CPU_COUNT}"
#export DynamicMetaStorms=${PREFIX}/bin
install -v -m 0755 bin/* ${PREFIX}/bin

cp -rf databases ${PREFIX}
cp -rf example ${PREFIX}
