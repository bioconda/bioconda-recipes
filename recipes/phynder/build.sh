#!/bin/bash
set -x
set +e

export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export CXX=${CXX}

# git clone https://github.com/samtools/htslib.git
# cd htslib
# git submodule update --init --recursive

# make lib-static htslib_static.mk

## Borrowed from amplisim
git clone --recursive https://github.com/samtools/htslib.git
cd htslib
ls -l
git reset --hard 7f5136f
ls -l
cd htscodecs
ls -l
git reset --hard 11b5007
cd ..
ls -l
make -C . CC=${CC} CFLAGS="${CFLAGS} -g -Wall -O2 -fvisibility=hidden" LDFLAGS="${LDFLAGS} -fvisibility=hidden" lib-static
ls -l
mkdir -p build
ls -l
./configure CPPFLAGS="${CPPFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    CXX=${CXX} \
    CC=${CC}

## FAILING HERE: THE SAMTOOLS HTSLIB COMPILATION IS NOT WORKING
## CHECK HTSLIB INSTALLATION DOCS? TRYING CONFIGURE ABOVE...
make CXX=${CXX} CXXFLAGS="${CXXFLAGS}" LDLIBS="${LDFLAGS}"
cd ../
ls -l
sed -i 's#HTSDIR=../htslib#HTSDIR=./htslib#g' Makefile
sed -i 's/$@ $(LDLIBS)/$@ $(LDLIBS) $(CFLAGS) $(LDFLAGS)/g' Makefile

make CXX=${CXX} CXXFLAGS="${CXXFLAGS}" LDLIBS="${LDFLAGS}"
make install
