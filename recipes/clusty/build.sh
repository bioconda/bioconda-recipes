#!/bin/bash

uname_S=`uname -s 2>/dev/null || echo not`

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

if [[ "$uname_S" == "Darwin" ]]; then
	make -j"${CPU_COUNT}" CXX="${CXX}" LDFLAGS="${LDFLAGS}";
else
	make LEIDEN=true -j"${CPU_COUNT}" CXX="${CXX}" LDFLAGS="${LDFLAGS}";
fi

install -d "${PREFIX}/bin"
install -v -m 0755 clusty "${PREFIX}/bin"
