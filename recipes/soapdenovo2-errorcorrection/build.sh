#!/bin/sh
set -x -e

mkdir -p $PREFIX/bin

export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
cd rbluo/temp/ecProj/src
$CXX connect.cpp  correct.cpp  ec.cpp  general.cpp  gzstream.cpp  kmerFreq.cpp  seqKmer.cpp -O4 -fomit-frame-pointer -o ${PREFIX}/bin/ErrorCorrection -lz
