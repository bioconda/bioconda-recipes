#!/bin/bash
export LDFLAGS="-L$PREFIX/lib"
export CFLAGS="-I$SRC_DIR -I$SRC_DIR/LIBDEFLATE -I$SRC_DIR/LIBDEFLATE/common -I$PREFIX/include -L$PREFIX/lib"
export CPPFLAGS="-I$SRC_DIR -I$SRC_DIR/LIBDEFLATE -I$SRC_DIR/LIBDEFLATE/common -I$PREFIX/include -L$PREFIX/lib"

# pretend HTSLIB has been built
touch libhts.a
# build LIBDEFLATE
cd LIBDEFLATE
make
cd -
# build fastk
make
make install
