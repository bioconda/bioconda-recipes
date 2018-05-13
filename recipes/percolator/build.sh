#!/bin/bash

mkdir percobuild && cd percobuild
cmake -DTARGET_ARCH=x86_64 -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PREFIX -DXML_SUPPORT=ON -DCMAKE_PREFIX_PATH="$PREFIX;$PREFIX/lib" $SRC_DIR
make && make install
cd ..

mkdir converterbuild && cd converterbuild 
cmake -DTARGET_ARCH=x86_64 -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PREFIX -DBOOST_ROOT=$PREFIX -DBOOST_LIBRARYDIR=$PREFIX/lib -DSERIALIZE="TokyoCabinet" -DCMAKE_PREFIX_PATH=$PREFIX $SRC_DIR/src/converters
make && make install
cd ..

mkdir $PREFIX/testdata
cp $SRC_DIR/src/converters/data/converters/sqt2pin/target.sqt $PREFIX/testdata/target.sqt
cp $SRC_DIR/data/percolator/tab/percolatorTab $PREFIX/testdata/percolatorTab

