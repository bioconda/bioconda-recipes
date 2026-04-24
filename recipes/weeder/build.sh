#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++14"

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

export TGT="${PREFIX}/share/weeder2"
mkdir -p ${PREFIX}/bin
mkdir -p ${TGT}

cp -rf FreqFiles ${TGT}
"${CXX}" ${CPPFLAGS} ${CXXFLAGS} ${LDFLAGS} weeder2.cpp -o ${TGT}/weeder2

cp -f ${RECIPE_DIR}/weeder2.py ${PREFIX}/bin/weeder2
chmod 0755 ${PREFIX}/bin/weeder2
