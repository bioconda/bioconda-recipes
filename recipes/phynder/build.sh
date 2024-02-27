#!/bin/bash
set -x
set +e

export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

# git clone https://github.com/samtools/htslib.git
# cd htslib
# git submodule update --init --recursive

# make lib-static htslib_static.mk

## Borrowed from amplisim
git clone --recursive https://github.com/samtools/htslib.git
cd htslib
git reset --hard 7f5136f
cd htscodecs
git reset --hard 11b5007
cd ..
make -C htslib CC=${CC} CFLAGS="${CFLAGS} -g -Wall -O2 -fvisibility=hidden" LDFLAGS="${LDFLAGS} -fvisibility=hidden" lib-static
mkdir -p build
make CXX=${CXX} CXXFLAGS="${CXXFLAGS} -O3 -DNDEBUG -Wno-missing-field-initializers -Wno-unused-function" LDLIBS="${LDFLAGS}"
cd ../

sed -i 's#HTSDIR=../htslib#HTSDIR=./htslib#g' Makefile
sed -i 's/$@ $(LDLIBS)/$@ $(LDLIBS) $(CFLAGS) $(LDFLAGS)/g' Makefile

make
make install
