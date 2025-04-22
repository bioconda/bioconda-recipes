#!/bin/bash
set -x -e

export CPATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -Wno-unused-result -Wno-format -Wno-implicit-function-declaration"

mkdir -p ${PREFIX}/bin

cd src/
make CC="${CC}" CFLAGS="${CFLAGS}" -j"${CPU_COUNT}"
make install
install -v -m 0755 ../bin/* "${PREFIX}/bin"

# add read permissions to LICENSE
chmod a+r "${SRC_DIR}/LICENSE"
