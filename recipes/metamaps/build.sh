#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

./bootstrap.sh
./configure --with-boost=${PREFIX} --prefix=${PREFIX}
make metamaps

mkdir -p $PREFIX/bin
cp -f metamaps $PREFIX/bin/

# Copy dependencies to bin dir until there is a better solution
cp *.pl *.R $PREFIX/bin/
cp -r perlLib $PREFIX/bin/
cp -r util $PREFIX/bin/
