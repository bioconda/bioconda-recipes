#!/bin/bash
set -x
set +e

export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

git clone https://github.com/samtools/htslib.git
cd htslib
git submodule update --init --recursive

make lib-static htslib_static.mk

cd ../

sed -i 's#HTSDIR=../htslib#HTSDIR=./htslib#g' Makefile
sed -i 's/$@ $(LDLIBS)/$@ $(LDLIBS) $(CFLAGS) $(LDFLAGS)/g' Makefile

make
make install
