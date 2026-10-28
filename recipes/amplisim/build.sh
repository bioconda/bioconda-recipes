#!/bin/sh

ls -l -a
cd lib
git clone --recursive https://github.com/samtools/htslib.git
cd htslib
git reset --hard 7f5136f
cd htscodecs
git reset --hard 11b5007
sed -i "1022c     return getauxval(AT_HWCAP) != 0;" htscodecs/rANS_static4x16pr.c
cd ../../..

make -C lib/htslib CC=${CC} CFLAGS="${CFLAGS} -g -Wall -O2 -fvisibility=hidden" LDFLAGS="${LDFLAGS} -fvisibility=hidden" lib-static

mkdir -p build
make CXX=${CXX} CXXFLAGS="${CXXFLAGS} -O3 -DNDEBUG -Wno-missing-field-initializers -Wno-unused-function" LDLIBS="${LDFLAGS}"

mkdir -p ${PREFIX}/bin
cp amplisim ${PREFIX}/bin
