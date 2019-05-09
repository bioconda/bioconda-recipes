#!/bin/bash

cd $SRC_DIR
mkdir -p lib
cp -r $PREFIX/include/* src/
cp -r $PREFIX/lib/* lib/
cp $PREFIX/lib/libBigWig.a lib/
make
cp -r lib/libwiggletools.a $PREFIX/lib/
cp -r inc/wiggletools.h $PREFIX/include/
cp bin/wiggletools $PREFIX/bin/
