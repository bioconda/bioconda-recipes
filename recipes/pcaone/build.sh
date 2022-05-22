#!/usr/bin/env bash

mkdir -p ${PREFIX}/bin
# fix zlib issue
export CFLAGS="-I$PREFIX/include"
export CXXFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
avx=1
if [ $(uname -s) == "Linux" ];then
  grep "avx2" /proc/cpuinfo |grep "fma" &>/dev/null
  [[ $? != 0 ]] && avx=0
fi
make MKLROOT=${PREFIX} AVX=$avx
mv PCAone ${PREFIX}/bin/
