#!/bin/bash


export C_INCLUDE_PATH="${PREFIX}/include"
export CPP_INCLUDE_PATH="${PREFIX}/include"
export CXX_INCLUDE_PATH="${PREFIX}/include"
export CPLUS_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"

mkdir -p $PREFIX/bin

cd $SRC_DIR/src/

make

cd $SRC_DIR/bin/
cp addTaxonNames $PREFIX/bin
cp convertNR $PREFIX/bin
cp gbk2faa.pl $PREFIX/bin
cp kaiju $PREFIX/bin
cp kaiju2krona $PREFIX/bin
cp kaijup $PREFIX/bin
cp kaijuReport $PREFIX/bin
cp kaijux $PREFIX/bin
cp makeDB.sh $PREFIX/bin
cp mergeOutputs $PREFIX/bin
cp mkbwt $PREFIX/bin
cp mkfmi $PREFIX/bin
cp convert_mar_to_kaiju.py $PREFIX/bin
cp taxonlist.tsv $PREFIX/bin
