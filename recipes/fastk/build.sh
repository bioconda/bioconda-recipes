#!/bin/bash

set -xe

export LDFLAGS="${LDFLAGS} -L$SRC_DIR/HTSLIB -L$PREFIX/lib"
export CFLAGS="${CFLAGS} -O3 -I$SRC_DIR -I$SRC_DIR/HTSLIB -I$SRC_DIR/LIBDEFLATE -I$SRC_DIR/LIBDEFLATE/common -I$PREFIX/include -L$SRC_DIR/HTSLIB -L$PREFIX/lib -Wno-unused-result -Wno-format -Wno-implicit-function-declaration"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include -I$SRC_DIR -I$SRC_DIR/HTSLIB -I$SRC_DIR/LIBDEFLATE -I$SRC_DIR/LIBDEFLATE/common -L$SRC_DIR/HTSLIB -L$PREFIX/lib"

# build HTSLIB
cd HTSLIB
make CC="${CC}" CFLAGS="${CFLAGS}" -j"${CPU_COUNT}" lib-static
cd -
# build LIBDEFLATE
cd LIBDEFLATE
make CFLAGS="${CFLAGS}" -j"${CPU_COUNT}"
cd -
# build fastk
make CC="${CC}" CFLAGS="${CFLAGS}" -j"${CPU_COUNT}"
make install
