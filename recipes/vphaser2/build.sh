#!/bin/bash
set -e -x -o pipefail

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -fopenmp -O3 -std=c++14 -I${PREFIX}/include/"

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

mkdir -p "$PREFIX/bin"

# This is all the makefile does and it's simpler to just recreate it than to patch things
cd V-Phaser-2.0/src

${CXX} ${CXXFLAGS} -I${PREFIX}/include/boost -I${PREFIX}/include/bamtools -L${PREFIX}/lib *.cpp -o ${PREFIX}/bin/vphaser2 -lbamtools -lz -pthread

ln -sf ${PREFIX}/bin/vphaser2 ${PREFIX}/bin/variant_caller
