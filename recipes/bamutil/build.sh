#!/usr/bin/env bash

VERSION=1.0.14
wget -O libStatGen-v$VERSION.tar.gz https://github.com/statgen/libStatGen/archive/v$VERSION.tar.gz
tar -xzvpf libStatGen-v$VERSION.tar.gz
make LIB_PATH_GENERAL=./libStatGen-$VERSION
make install INSTALLDIR=$PREFIX LIB_PATH_GENERAL=./libStatGen-$VERSION
mkdir -p $PREFIX/bin/
mv $PREFIX/bam $PREFIX/bin/
