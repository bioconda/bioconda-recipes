#!/bin/bash

mkdir -pv $PREFIX/bin
mkdir -pv $PREFIX/MegaPath
cp -rv ac-diamond-0.1-beta-linux64 bbmap calcAccuracy.pl cc cleanup.pl extractFromLSAM.pl extractViralAndUnmap.pl fastq2fasta.pl LICENSE m8_to_lsam.pl m8_to_mapLen_hist.cpp maskLowerWithN.pl merge_dpout.sh r2c_to_r2g.pl README_LSAM.md README.md reassign.pl runBBduk.pl runMegaPath.sh runSOAP3dp.pl sam2cfq.pl soap4 sortedBam2Snapshot splitFasta.pl $PREFIX/MegaPath
ln -s $PREFIX/MegaPath/runMegaPath.sh $PREFIX/bin

export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export CPATH=${PREFIX}/include
make CC=$CXX CXX=${CXX} -C $PREFIX/MegaPath/soap4/2bwt-lib/ 
make CC=$CXX CXX=${CXX} CXXFLAGS="${CXXFLAGS} -L${PREFIX}/lib -msse4.1 -pthread -lpthread -fopenmp" LDFLAGS="${LDFLAGS}" -C $PREFIX/MegaPath/soap4/ 
