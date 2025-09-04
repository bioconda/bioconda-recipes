#!/bin/bash

set -xe
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p "${PREFIX}/bin"

dos2unix src/*
patch -p1 < ${RECIPE_DIR}/0001-Makefile.patch
patch -p1 < ${RECIPE_DIR}/0002-Fix-missing-pointer-deref.patch
patch -p1 < ${RECIPE_DIR}/0003.patch

cd src/

# without -fpermissive, this fails with GCC7 due to bad style
make CXX="${CXX}" \
	CXXFLAGS+="-Wno-conversion-null -Wno-unused-result -Wno-register -Wno-aggressive-loop-optimizations" \
	LDFLAGS+="-pthread -lm -lexpat" \
	-j"${CPU_COUNT}"

install -v -m 0755 ../bin/tandem.exe "${PREFIX}/bin"
ln -sf "${PREFIX}/bin/tandem.exe" "${PREFIX}/bin/xtandem"
