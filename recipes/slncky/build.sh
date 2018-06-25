#!/bin/bash

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

cp -R $SRC_DIR/* $PREFIX/bin
cd $PREFIX/bin
chmod a+x slncky.v1.0
ln slncky.v1.0 slncky
pwd
ls -l
