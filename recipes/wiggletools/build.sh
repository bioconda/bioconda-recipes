#!/bin/bash

cd $SRC_DIR
mkdir -p lib
cp -r $PREFIX/include/* src/
cp -r $PREFIX/lib/* lib/
cp $PREFIX/lib/libBigWig.a lib/
make LIBS="-lwiggletools -l:libBigWig.a -lcurl -l:libhts.a -lgsl  -lgslcblas -lz -lpthread -lm -llzma -lbz2 -ldl -ldeflate"
cp lib/libwiggletools.a $PREFIX/lib/
cp inc/wiggletools.h $PREFIX/include/
cp bin/wiggletools $PREFIX/bin/
