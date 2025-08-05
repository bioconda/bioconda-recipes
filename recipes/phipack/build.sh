#!/bin/bash

# There's a . directory that's ignored on OSX but not Linux
if [[ "$(uname -s)" == "Darwin" ]]; then
	cd src
else
	cd PhiPack/src/
fi

mkdir -p "$PREFIX/bin"

make CXX="${CC}" CXXFLAGS="${CFLAGS}" -j"${CPU_COUNT}"

install -v -m 0755 Phi Profile "${PREFIX}/bin"
cp -rf ppma_2_bmp "$PREFIX/bin"
