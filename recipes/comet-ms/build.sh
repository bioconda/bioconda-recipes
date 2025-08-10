#!/bin/bash
set -e
set -x

export INCLUDE_PATH="${PREFIX}/MSToolkit/include"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include -I${PREFIX}/MSToolkit/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"
export CFLAGS="${CFLAGS} -O3 -Wno-deprecated-declarations"

mkdir -p "$PREFIX/bin"

# To switch from static to dynamic linking on linux. The Makefile does not have this flag for macOS
# Dynamic linking does not work with mulled container tests
#sed -i.bak 's#-static##' Makefile
sed -i.bak "s#gcc#${CC}#;s#g++#${CXX}#" MSToolkit/Makefile
sed -i.bak "s#gcc#${CC}#;s#g++#${CXX}#" CometSearch/Makefile

make CXX="${CXX}" -j"${CPU_COUNT}"

install -v -m 755 comet.exe "${PREFIX}/bin"

ln -sf $PREFIX/bin/comet.exe comet
