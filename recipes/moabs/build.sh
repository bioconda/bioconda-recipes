#!/bin/bash

export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L${PREFIX}/lib"

make
make install
mkdir -p ${PREFIX}
rsync -av ${SRC_DIR}/bin/ ${PREFIX}/bin
