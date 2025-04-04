#!/bin/bash

if [ "${DOCS_RS}" = "1" ]
then
	exit 0
fi

set -ex

pushd ${OUT_DIR}

HTSLIB_VERSION=${1}

rm -rf ${OUT_DIR}/htslib

git clone -b ${HTSLIB_VERSION} http://github.com/samtools/htslib.git

cd htslib

cat > config.h << CONFIG_H
#define HAVE_LIBBZ2 1
#define HAVE_DRAND48 1
CONFIG_H

perl -i -pe 's/hfile_libcurl\.o//g' Makefile
	
function is_musl() {
	if [ ! -z $(echo $TARGET | grep musl) ]; then 
		return 0
	else
		return 1
	fi
}

is_musl && perl -i -pe 's/gcc/musl-gcc/g' Makefile


if [ "x${ZLIB_SRC}" != "x" ]
then
	tar xz ${ZLIB_SRC}
else
	curl -L 'http://github.com/madler/zlib/archive/refs/tags/v1.2.11.tar.gz' | tar xz
fi
cd zlib-1.2.11
is_musl && CC=musl-gcc ./configure || ./configure
make libz.a
cp libz.a ..
cd ..

#The original file in the repo is lacking -L in the curl command so it doen't work
curl -L http://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz | tar xz
cd bzip2-1.0.8
is_musl && perl -i -pe 's/gcc/musl-gcc/g' Makefile
is_musl || perl -i -pe 's/CFLAGS=/CFLAGS=-fPIC /g' Makefile
make
cp libbz2.a ..
cd ..

perl -i -pe 's/CPPFLAGS =/CPPFLAGS = -Izlib-1.2.11 -Ibzip2-1.0.8/g' Makefile

is_musl || perl -i -pe 's/CFLAGS *=/CFLAGS = -fPIC/g' Makefile

make -j8 lib-static