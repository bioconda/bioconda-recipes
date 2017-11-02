#!/bin/bash

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

echo "###########################################################"
echo $PREFIX
echo "###########################################################"
cd $SRC_DIR
mkdir -p lib
cp -r $PREFIX/include/* src
cp -r $PREFIX/lib/* lib/
cp $PREFIX/lib/libBigWig.a lib
make
cp -r lib/libwiggletools.a $PREFIX/lib
cp bin/wiggletools $PREFIX/bin
