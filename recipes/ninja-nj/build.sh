#!/bin/bash
set -x -e

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

if [[ $(uname) == "Darwin" ]]; then
	export CXXFLAGS="${CXXFLAGS}"
	export CXXFLAGS="${CXXFLAGS} -Wno-deprecated-register -Wno-unused-but-set-variable -Wno-unused-variable -Wno-format -Wno-deprecated-declarations"
else
	export CXXFLAGS="${CXXFLAGS} -lrt"
fi

mkdir -p ${PREFIX}/bin

cd NINJA/
make all CXX="${CXX}" CXXFLAGS="${CXXFLAGS}" -j"${CPU_COUNT}"
install -v -m 0755 Ninja ${PREFIX}/bin
