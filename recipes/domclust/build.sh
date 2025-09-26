#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -fcommon -Wno-deprecated-non-prototype -Wno-implicit-function-declaration -Wno-implicit-int"

mkdir -p "$PREFIX/bin"

sed -i.bak 's|-g -O2 $(CFLAGS0)|-g -O3 $(CFLAGS0) -Xlinker -zmuldefs -Wno-deprecated-non-prototype -Wno-implicit-function-declaration -Wno-implicit-int|' Makefile

if [[ "$(uname -s)" == "Darwin" ]]; then
	sed -i.bak 's|-Xlinker -zmuldefs||' Makefile
fi

rm -f *.bak

make CC="${CC}" -j1

# copy binary to prefix folder
install -v -m 0755 bin/domclust Script/*.pl build_input/*.pl "${PREFIX}/bin"
