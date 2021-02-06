#!/bin/bash
export C_INCLUDE_PATH=$PREFIX/include/
export CPLUS_INCLUDE_PATH=$PREFIX/include/

cd src
make CC=$CXX LDFLAGS="$LDFLAGS -L$PREFIX/lib"
