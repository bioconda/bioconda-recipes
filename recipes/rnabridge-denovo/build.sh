#!/bin/bash
export C_INCLUDE_PATH=$PREFIX/include/
export CPLUS_INCLUDE_PATH=$PREFIX/include/
export  LDFLAGS=$LDFLAGS:-L$PREFIX/lib

cd src
make CC=$CXX
