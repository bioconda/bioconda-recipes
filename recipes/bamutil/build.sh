#!/usr/bin/env bash

VERSION=1.0.14
SHA256=70a504c5cc4838c6ac96cdd010644454615cc907df4e3794c999baf958fa734b
curl -Lo libStatGen-v$VERSION.tar.gz https://github.com/statgen/libStatGen/archive/v$VERSION.tar.gz
RETRIEVED_SHA256=$(openssl sha256 libStatGen-v$VERSION.tar.gz)
[[ ${RETRIEVED_SHA256##* } == $SHA256 ]] || exit 1

tar -xzvpf libStatGen-v$VERSION.tar.gz
make LIB_PATH_GENERAL=./libStatGen-$VERSION
make install INSTALLDIR=$PREFIX LIB_PATH_GENERAL=./libStatGen-$VERSION
mkdir -p $PREFIX/bin/
mv $PREFIX/bam $PREFIX/bin/
