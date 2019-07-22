#!/bin/bash

export CPATH="${PREFIX}/include"
export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I$PREFIX/include"
export LIBRARY_PATH=${PREFIX}/lib

make
make install
mkdir -p ${PREFIX}
rsync -av ${SRC_DIR}/bin/ ${PREFIX}/bin
