#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++14"

mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/opt/crispritz"

sed -i.bak 's|#include <parallel/algorithm>|#include <algorithm>|' sourceCode/CRISPR-Cas-Tree/mainParallel.cpp

make -f Makefile_conda \
    CXX="${CXX} ${CPPFLAGS} ${CXXFLAGS} ${LDFLAGS}" \
    BUILD_PREFIX="${PREFIX}"

chmod -R 700 .

install -v -m 0755 crispritz.py "${PREFIX}/bin"

cp -Rf buildTST \
	searchTST \
	searchBruteForce \
	sourceCode/Python_Scripts \
	"${PREFIX}/opt/crispritz/"
