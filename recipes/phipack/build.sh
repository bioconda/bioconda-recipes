#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"

mkdir -p "$PREFIX/bin"

# There's a . directory that's ignored on OSX but not Linux
#
if [[ "$(uname -s)" == "Darwin" ]]; then
	export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib"
	cd src
else
	cd PhiPack/src/
fi

make CXX="${CC}" CXXFLAGS="${CFLAGS}"

install -v -m 0755 Phi Profile "${PREFIX}/bin"

cp -rf ppma_2_bmp $PREFIX/bin/
