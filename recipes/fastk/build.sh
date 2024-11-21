#!/bin/bash

set -xe

export LDFLAGS="-L$SRC_DIR/HTSLIB -L$PREFIX/lib"
export CFLAGS="-I$SRC_DIR -I$SRC_DIR/HTSLIB -I$SRC_DIR/LIBDEFLATE -I$SRC_DIR/LIBDEFLATE/common -I$PREFIX/include -L$SRC_DIR/HTSLIB -L$PREFIX/lib"
export CPPFLAGS="-I$SRC_DIR -I$SRC_DIR/HTSLIB -I$SRC_DIR/LIBDEFLATE -I$SRC_DIR/LIBDEFLATE/common -I$PREFIX/include -L$SRC_DIR/HTSLIB -L$PREFIX/lib"

# build HTSLIB
cd HTSLIB
make -j"${CPU_COUNT}" lib-static
cd -
# build LIBDEFLATE
cd LIBDEFLATE
make -j"${CPU_COUNT}"
cd -
# build fastk
make -j"${CPU_COUNT}"
make install
