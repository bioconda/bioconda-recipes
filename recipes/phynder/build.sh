#!/bin/bash
set -x
set +e

export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export CPATH=${PREFIX}/include

git clone https://github.com/samtools/htslib.git
cd htslib
git submodule update --init --recursive

## from https://github.com/pachterlab/kallisto/issues/303#issuecomment-884612169
sed '/AC_PROG_CC/a \
AC_CANONICAL_HOST \
AC_PROG_INSTALL \
' configure.ac >configure.ac2
mv configure.ac2 configure.ac
autoreconf -i
autoheader
autoconf

./configure --prefix=${PREFIX} --enable-libcurl --with-libdeflate --enable-plugins --enable-gcs --enable-s3
make lib-static htslib_static.mk
make CC=$CC install

cd ../

sed -i 's#HTSDIR=../htslib#HTSDIR=./htslib#g' Makefile

## TODO:
## sed patch LDLIBS to add LDFLAGS to the end of line
## sed patch Turn off copying

sed -i -e 's#LDLIBS=$(HTSLIB) -lpthread $(HTSLIB_static_LIBS)#LDLIBS=$(HTSLIB) -lpthread $(HTSLIB_static_LIBS)#g' -e 's#cp phynder ~/bin##g' Makefile

make CC=$CC CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS"
make install # Remaining error: ./phynder: error while loading shared libraries: libbz2.so.1.0: cannot open shared object file: No such file or directory
