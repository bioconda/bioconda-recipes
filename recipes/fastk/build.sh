#!/bin/bash
export LDFLAGS="-L$SRC_DIR/HTSLIB -L$PREFIX/lib"
export CFLAGS="-I$SRC_DIR -I$SRC_DIR/HTSLIB -I$SRC_DIR/LIBDEFLATE -I$SRC_DIR/LIBDEFLATE/common -I$PREFIX/include -L$SRC_DIR/HTSLIB -L$PREFIX/lib"
export CPPFLAGS="-I$SRC_DIR -I$SRC_DIR/HTSLIB -I$SRC_DIR/LIBDEFLATE -I$SRC_DIR/LIBDEFLATE/common -I$PREFIX/include -L$SRC_DIR/HTSLIB -L$PREFIX/lib"

# build HTSLIB
cd HTSLIB
make lib-static
cd -
# build LIBDEFLATE
cd LIBDEFLATE
make
cd -
# build fastk
make
make install
