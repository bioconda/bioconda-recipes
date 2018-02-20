#!/usr/bin/env bash

VERSION=1.0.14
curl -o libStatGen-v$VERSION.tar.gz -L https://github.com/statgen/libStatGen/archive/v$VERSION.tar.gz
tar -xzvpf libStatGen-v$VERSION.tar.gz
#sed -i -e 's/-pg//' libStatGen-1.0.14/Makefiles/Makefile.include
make LIB_PATH_GENERAL=./libStatGen-$VERSION
make install INSTALLDIR=$PREFIX LIB_PATH_GENERAL=./libStatGen-$VERSION
mkdir -p $PREFIX/bin/
mv $PREFIX/bam $PREFIX/bin/
