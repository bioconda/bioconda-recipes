#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++14 -D_GLIBCXX_PARALLEL"

mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/opt/crispritz"

case $(uname -m) in
    aarch64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8-a"
	;;
    arm64)
	export CXXFLAGS="${CXXFLAGS} -march=armv8.4-a"
	;;
    x86_64)
	export CXXFLAGS="${CXXFLAGS} -march=x86-64-v3"
	;;
esac

#sed -i.bak 's|#include <parallel/algorithm>|#include <algorithm>|' sourceCode/CRISPR-Cas-Tree/mainParallel.cpp
case $(uname -s) in
    "Darwin")
        export CXX="${CXX} -stdlib=libstdc++"
		export LDFLAGS="${LDFLAGS} -lstdc++"
        ;;
esac
rm -f *.bak

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
