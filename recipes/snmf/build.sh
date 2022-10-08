#!/bin/bash

SNMF_HOME=$PREFIX/share/${PKG_NAME}_v$PKG_VERSION

mkdir -p $SNMF_HOME
mv src/* $SNMF_HOME/

mkdir -p $SNMF_HOME/bin
mkdir -p $SNMF_HOME/code/lib/
mkdir -p $SNMF_HOME/code/obj
mkdir -p $SNMF_HOME/code/obj/bituint
mkdir -p $SNMF_HOME/code/obj/convert
mkdir -p $SNMF_HOME/code/obj/createDataSet
mkdir -p $SNMF_HOME/code/obj/crossEntropy
mkdir -p $SNMF_HOME/code/obj/io
mkdir -p $SNMF_HOME/code/obj/lapack
mkdir -p $SNMF_HOME/code/obj/main
mkdir -p $SNMF_HOME/code/obj/matrix
mkdir -p $SNMF_HOME/code/obj/nnlsm
mkdir -p $SNMF_HOME/code/obj/sNMF
mkdir -p $SNMF_HOME/code/obj/stats

cd $SNMF_HOME

pushd code
make clean
make CC="${CC}" CFLAGS+=' -fcommon -lm -lpthread'
popd

mkdir -p $PREFIX/bin
cp $SNMF_HOME/bin/* ${PREFIX}/bin
