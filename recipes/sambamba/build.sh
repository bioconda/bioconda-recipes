#!/bin/bash
set -eu

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

if [ $(uname) == "Darwin" ]; then
    export LDFLAGS="-headerpad_max_install_names $LDFLAGS"
fi
sed -i.bak 's/ gcc / $(CC) /g' Makefile
cd htslib && make CC=$CC LDFLAGS="-L$PREFIX/lib" && cd ..
make CC=$CC LIBRARY_PATH=$PREFIX/lib
make test
mkdir -p ${PREFIX}/bin
cp bin/sambamba ${PREFIX}/bin/sambamba
