#!/bin/bash

#make -C src \
#  BUILD_DIR="$( pwd )/build" \
#  TARGET_DIR="${PREFIX}" \
#  CC="${CC}" \
#  CXX="${CXX}"

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/lib

if [ `uname` == Darwin ]; then
	cp meryl-${PKG_VERSION}-darwin/bin/* ${PREFIX}/bin/
	cp meryl-${PKG_VERSION}-darwin/lib/* ${PREFIX}/lib/
	else
	cp meryl-${PKG_VERSION}-linux/bin/* ${PREFIX}/bin/
	cp meryl-${PKG_VERSION}-linux/lib/* ${PREFIX}/lib/
fi

rm "${PREFIX}/lib/libmeryl.a"

chmod 0755 ${PREFIX}/bin/meryl-*
chmod 0755 ${PREFIX}/bin/meryl
chmod 0755 ${PREFIX}/bin/position-lookup
