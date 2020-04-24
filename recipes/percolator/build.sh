#!/bin/bash

mkdir percobuild && cd percobuild
cmake -DTARGET_ARCH=x86_64 -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PREFIX -DXML_SUPPORT=ON -DCMAKE_PREFIX_PATH="$PREFIX;$PREFIX/lib" -DCMAKE_CXX_FLAGS="-std=c++14" $SRC_DIR
make && make install
cd ..

# First make sure we dont get problems with truncated PREFIX due to null terminators:
# see percolator/percolator#251 and conda/conda-build#1674
sed -i '54s/WRITABLE_DIR/std::string(WRITABLE_DIR).c_str()/' $SRC_DIR/src/Globals.cpp
mkdir converterbuild && cd converterbuild 
cmake -DTARGET_ARCH=x86_64 -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$PREFIX" -DBOOST_ROOT=$PREFIX -DBOOST_LIBRARYDIR=$PREFIX/lib -DSERIALIZE="Boost" -DCMAKE_CXX_FLAGS="-std=c++11" -DCMAKE_PREFIX_PATH="$PREFIX" $SRC_DIR/src/converters
make install
cd ..

mkdir $PREFIX/testdata
cp $SRC_DIR/src/converters/data/converters/sqt2pin/target.sqt $PREFIX/testdata/target.sqt
cp $SRC_DIR/src/converters/data/converters/msgf2pin/target.mzid $PREFIX/testdata/target.mzid
cp $SRC_DIR/src/converters/data/converters/tandem2pin/target.t.xml $PREFIX/testdata/target.t.xml
cp $SRC_DIR/data/percolator/tab/percolatorTab $PREFIX/testdata/percolatorTab
