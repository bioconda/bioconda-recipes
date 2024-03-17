#!/bin/bash

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

make LIB_PATH_GENERAL="${PREFIX}"/lib

cp fastQValidator "${PREFIX}"/bin
