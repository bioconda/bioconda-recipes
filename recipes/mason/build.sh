#!/bin/bash

BINARY_HOME=$PREFIX/bin
PKG_HOME=$PREFIX/opt/$PKG_NAME-$PKG_VERSION

cd $SRC_DIR/bin

binaries="\
mason_frag_sequencing \
mason_genome \
mason_materializer \
mason_methylation \
mason_simulator \
mason_splicing \
mason_variator \
"
mkdir -p $PREFIX/bin
mkdir -p $PKG_HOME

for i in $binaries; do cp $SRC_DIR/bin/$i $PKG_HOME/$i && chmod a+x $PKG_HOME/$i && ln -s $PKG_HOME/$i $BINARY_HOME/$i; done
