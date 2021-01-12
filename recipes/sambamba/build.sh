#!/bin/bash
set -eu

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

if [ $(uname) == "Darwin" ]; then
    export LDFLAGS="-headerpad_max_install_names $LDFLAGS"
fi
sed -i.bak 's/ gcc / $(CC) /g' Makefile
make CC=$CC LIBRARY_PATH=$PREFIX/lib
make test
mkdir -p ${PREFIX}/bin
ls -l bin
cp bin/sambamba-${PKG_VERSION} ${PREFIX}/bin/sambamba
