#!/bin/bash
set -x
set +e

mkdir -p $PREFIX/bin

export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export C_INCLUDE_PATH="${PREFIX}/include"

## Static lib required by phynder, thus following instructions
## rather than trying to take from a conda htslib
git clone https://github.com/samtools/htslib.git
cd htslib
git submodule update --init --recursive

## from https://github.com/pachterlab/kallisto/issues/303#issuecomment-884612169
sed '/AC_PROG_CC/a \
AC_CANONICAL_HOST \
AC_PROG_INSTALL \
' configure.ac > configure.ac2
mv configure.ac2 configure.ac
autoreconf -if

./configure --prefix=${PREFIX} --enable-libcurl --with-libdeflate --enable-plugins --enable-gcs --enable-s3
make -j "${CPU_COUNT}" lib-static htslib_static.mk
make CC=$CC install

## Patch phynder Makefile to cloned htslib folder (original assumes alongside, not within)
cd ../
sed -i.bak 's#HTSDIR=../htslib#HTSDIR=./htslib#g' Makefile
sed -i.bak -e 's#LDLIBS=$(HTSLIB) -lpthread $(HTSLIB_static_LIBS)#LDLIBS=$(HTSLIB) -lpthread $(HTSLIB_static_LIBS) $(LDFLAGS)#g' -e 's#cp phynder ~/bin##g' Makefile

make CC=$CC CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS" -j "${CPU_COUNT}"
make install

chmod 755 phynder
cp -f phynder $PREFIX/bin/
