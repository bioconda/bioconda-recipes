#!/bin/bash
set -x
set +e

export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

git clone https://github.com/samtools/htslib.git
cd htslib
git submodule update --init --recursive

sed -i.bak 's/^CPPFLAGS =$//g' Makefile
sed -i.bak 's/^LDFLAGS  =$//g' Makefile

sed -i.bak 's/^CPPFLAGS =$//g' htslib-$PKG_VERSION/Makefile
sed -i.bak 's/^LDFLAGS  =$//g' htslib-$PKG_VERSION/Makefile

make lib-static htslib_static.mk

cd ../

sed -i.bak 's/^CPPFLAGS =$//g' Makefile
sed -i.bak 's/^LDFLAGS  =$//g' Makefile

sed -i.bak 's/^CPPFLAGS =$//g' htslib-$PKG_VERSION/Makefile
sed -i.bak 's/^LDFLAGS  =$//g' htslib-$PKG_VERSION/Makefile

sed -i 's#HTSDIR=../htslib#HTSDIR=./htslib#g' Makefile

make
make install
