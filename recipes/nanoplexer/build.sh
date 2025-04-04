#!/bin/bash

mkdir -p $PREFIX/bin
make CC=$CC CFLAGS="$CFLAGS -L${PREFIX}/lib"
cp ./nanoplexer $PREFIX/bin/nanoplexer
