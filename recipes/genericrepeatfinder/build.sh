#!/bin/bash
set -x -e

export CFLAGS="${CFLAGS} -O3"
export CPPFLAGS="${CPPFLAGS} -I$PREFIX/include"
export CXXFLAGS="${CXXFLAGS} -O3 -Wall -std=c++14 -fopenmp -I$PREFIX/include"
export LDFLAGS="${LDFLAGS} -L$PREFIX/lib"

mkdir -p "${PREFIX}/bin"

cd src

make CC="${CXX}" CFLAGS="${CXXFLAGS}" -j"${CPU_COUNT}"

install -v -m 0755 grf-alignment/grf-alignment \
	grf-alignment2/grf-alignment2 \
	grf-dbn/grf-dbn \
	grf-filter/grf-filter \
	grf-intersperse/grf-intersperse \
	grf-main/grf-main \
	grf-mite-cluster/grf-mite-cluster \
	grf-nest/grf-nest "${PREFIX}/bin"
