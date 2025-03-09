#!/bin/bash
set -euo pipefail

export CFLAGS="${CFLAGS} -O3 -Wno-unused-command-line-argument -Wno-return-type -Wno-implicit-function-declaration -Wno-format -Wno-unused-comparison"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

mkdir -p ${PREFIX}/bin
cd source

if [[ `uname` == "Darwin" ]]; then
	rm Makefile.MAC_OS
	cp -rf ${RECIPE_DIR}/Makefile.MAC_OS .
	make -f Makefile.MAC_OS CC="${CC} -fcommon ${CFLAGS} ${LDFLAGS}" CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include" -j"${CPU_COUNT}"
else
	rm Makefile
	cp -rf ${RECIPE_DIR}/Makefile .
	make -f Makefile CC="${CC} -fcommon ${CFLAGS} ${LDFLAGS}" CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include" -j"${CPU_COUNT}"
fi

install -v -m 0755 dialign-tx ${PREFIX}/bin
