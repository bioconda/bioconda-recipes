#!/bin/bash

mkdir -pv $PREFIX/bin
mkdir -pv $PREFIX/MegaPath
cp -rv ac-diamond-0.1-beta-linux64 bbmap calcAccuracy.pl cc cleanup.pl extractFromLSAM.pl extractViralAndUnmap.pl fastq2fasta.pl LICENSE m8_to_lsam.pl m8_to_mapLen_hist.cpp maskLowerWithN.pl merge_dpout.sh r2c_to_r2g.pl README_LSAM.md README.md reassign.pl runBBduk.pl runMegaPath-Amplicon.sh runMegaPath.sh runSOAP3dp.pl sam2cfq.pl soap4 sortedBam2Snapshot splitFasta.pl scripts $PREFIX/MegaPath
cp -s $PREFIX/MegaPath/runMegaPath.sh $PREFIX/MegaPath/runMegaPath-Amplicon.sh $PREFIX/bin


export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export CPATH=${PREFIX}/include
make CC=$CXX CXX=${CXX} CXXFLAGS="${CXXFLAGS} -L${PREFIX}/lib -std=c++11 -g -O2 -Wall -std=c++0x -fopenmp -lz" LDFLAGS="${LDFLAGS}" -C $PREFIX/MegaPath/cc/ 
make CC=$CXX CXX=${CXX} -C $PREFIX/MegaPath/soap4/2bwt-lib/ 
make CC=$CXX CXX=${CXX} CXXFLAGS="${CXXFLAGS} -w -O3 -funroll-loops -march=native -maccumulate-outgoing-args -Wno-unused-result -static-libgcc -mavx -fopenmp -std=c++0x -fomit-frame-pointer" LDFLAGS="${LDFLAGS}" -C $PREFIX/MegaPath/soap4/ 

cd $PREFIX/MegaPath/scripts/realignment/realign/
$CXX -std=c++14 -O1 -shared -fPIC -o realigner ssw_cpp.cpp ssw.c realigner.cpp
$CXX -std=c++11 -shared -fPIC -o debruijn_graph -O3 debruijn_graph.cpp -I $PREFIX/include -L $PREFIX/lib
$CC -Wall -O3 -pipe -fPIC -shared -rdynamic -o libssw.so ssw.c ssw.h

