#!/bin/bash

mkdir -p $PREFIX/bin

make -f Makefile.conda CFLAGS="${CFLAGS} -I${PREFIX}/include -L${PREFIX}/lib" opt_lib=${PREFIX}/lib portable=1

chmod 0755 bin/longcallD
cp -f bin/longcallD $PREFIX/bin/
