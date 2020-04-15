#!/bin/bash


export C_INCLUDE_PATH="${PREFIX}/include"
export CPP_INCLUDE_PATH="${PREFIX}/include"
export CXX_INCLUDE_PATH="${PREFIX}/include"
export CPLUS_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"

mkdir -p $PREFIX/bin

cd $SRC_DIR/src/

make CC=${CC} CXX=${CXX}

cd $SRC_DIR/bin/
cp kaiju-addTaxonNames $PREFIX/bin
cp kaiju-convertNR $PREFIX/bin
cp kaiju-gbk2faa.pl $PREFIX/bin
cp kaiju $PREFIX/bin
cp kaiju2krona $PREFIX/bin
cp kaiju2table $PREFIX/bin
cp kaijup $PREFIX/bin
cp kaijux $PREFIX/bin
cp kaiju-makedb $PREFIX/bin
cp kaiju-mergeOutputs $PREFIX/bin
cp kaiju-mkbwt $PREFIX/bin
cp kaiju-mkfmi $PREFIX/bin
cp kaiju-convertMAR.py $PREFIX/bin
cp kaiju-taxonlistEuk.tsv $PREFIX/bin
cp kaiju-excluded-accessions.txt $PREFIX/bin
