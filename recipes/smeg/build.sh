#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir
mkdir -p $PREFIX/bin

export CXX=${PREFIX}/bin/g++

cd $SRC_DIR

cp *.R $outdir
cp README.md $outdir
cp *.cpp $outdir
cp smeg $outdir
chmod +x $outdir/smeg
g++ -std=c++11 $outdir/pileupParser.cpp -o $outdir/pileupParser
g++ -std=c++11 -pthread $outdir/uniqueSNPmultithreading.cpp -o $outdir/uniqueSNPmultithreading


ln -s $outdir/smeg $PREFIX/bin/smeg

