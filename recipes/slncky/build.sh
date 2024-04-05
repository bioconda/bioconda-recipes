#!/bin/bash

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

mkdir -p $PREFIX/bin
cp -R $SRC_DIR/* $PREFIX/bin
cd $PREFIX/bin
chmod a+x slncky.v1.0
chmod a+x makeWebsite
ln slncky.v1.0 slncky
pwd
ls -l
