#!/bin/bash

mkdir -p $PREFIX/bin

#flags for D compiler (splitrim.d)
export DFLAGS="-I$PREFIX/lib/dmd/src/phobos -I$PREFIX/lib/dmd/src/druntime/import -L-L$PREFIX/lib/dmd/linux/lib64 -L--export-dynamic"

cd $SRC_DIR/
./INSTALL.sh

cd bin/
cp *.pl $PREFIX/bin
cp splitrim $PREFIX/bin
