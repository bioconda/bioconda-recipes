#!/bin/bash
export LDFLAGS="-L$PREFIX/lib"
export CFLAGS="-I$SRC_DIR -I$PREFIX/include -L$PREFIX/lib"
export CPPFLAGS="-I$SRC_DIR -I$PREFIX/include -L$PREFIX/lib"

# pretend HTSLIB and LIBDEFLATE have been built
touch HTSLIB/libhts.a
touch LIBDEFLATE/libdeflate.a
touch libhts.a
touch deflate.lib
# build fastk
make
make install
