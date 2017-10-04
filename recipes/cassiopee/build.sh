#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include:$C_INCLUDE_PATH
export CPLUS_INCLUDE_PATH=${PREFIX}/include:$CPLUS_INCLUDE_PATH
export LIBRARY_PATH=${PREFIX}/lib:$LIBRARY_PATH
export LDFLAGS="-L$PREFIX/lib"

# DEBUG purpose to find boost related libs on travis
cmake -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX .
make
make install

