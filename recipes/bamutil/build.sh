#!/usr/bin/env bash

VERSION=1.0.14
curl -o libStatGen-v$VERSION.tar.gz -L https://github.com/statgen/libStatGen/archive/v$VERSION.tar.gz
openssl sha256 libStatGen-v$VERSION.tar.gz | grep 70a504c5cc4838c6ac96cdd010644454615cc907df4e3794c999baf958fa734b
tar -xzvpf libStatGen-v$VERSION.tar.gz
# remove profile flag to avoid "ld: cannot find gcrt1.o: No such file or directory"
sed -i.bak '/OPTFLAG_PROFILE?=/ s/-pg//' ./libStatGen-$VERSION/Makefiles/Makefile.include
export C_INCLUDE_PATH="${PREFIX}/include"
export CPP_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export CFLAGS="-I${PREFIX}/include"
make LIB_PATH_GENERAL=./libStatGen-$VERSION
make install INSTALLDIR=$PREFIX LIB_PATH_GENERAL=./libStatGen-$VERSION
mkdir -p $PREFIX/bin/
mv $PREFIX/bam $PREFIX/bin/
