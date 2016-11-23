#!/bin/bash

mkdir -p $PREFIX/bin

cd $SRC_DIR/linux/bin64/

chmod a+x ddemangle dman dmd dumpobj dustmite obj2asm rdmd

cp ddemangle dman dmd dumpobj dustmite obj2asm rdmd $PREFIX/bin

export DFLAGS="-I$SRC_DIR/src/phobos -I$SRC_DIR/src/druntime/import -L-L$SRC_DIR/linux/lib64 -L--export-dynamic"
