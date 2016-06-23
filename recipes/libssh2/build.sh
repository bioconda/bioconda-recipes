#!/bin/bash

export C_INCLUDE_PATH="$PREFIX/include"
export LIBRARY_PATH="$PREFIX/lib"

./configure --prefix=${PREFIX} --with-openssl --with-libz --with-libssl-prefix=${PRERIX} --with-libz-prefix=${PREFIX}
make
make install
