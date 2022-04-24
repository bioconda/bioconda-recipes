#!/bin/sh
set -x -e

cd rbluo/temp/ecProj/src

mkdir -p "${PREFIX}/bin"
"${CXX}" ${CXXFLAGS} ${CPPLAGS} ${LDFLAGS} \
    connect.cpp  correct.cpp  ec.cpp  general.cpp  gzstream.cpp  kmerFreq.cpp  seqKmer.cpp \
    -O4 -fomit-frame-pointer -o "${PREFIX}/bin/ErrorCorrection" -lz
