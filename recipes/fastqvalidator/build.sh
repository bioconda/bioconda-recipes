#!/bin/bash

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

make

cp fastQValidator "${PREFIX}"/bin
