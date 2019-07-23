#!/bin/bash

export CPATH="${PREFIX}/include"
export CPPFLAGS="-I${PREFIX}/include"
export LDFLAGS="-L${PREFIX}/lib -lstdc++"
export LIBRARY_PATH="${PREFIX}/lib"
export BOOSTINC="${PREFIX}/include"
export BOOSTLIB="${PREFIX}/lib"

make
make install
mkdir -p ${PREFIX}
rsync -av ${SRC_DIR}/bin/ ${PREFIX}/bin
