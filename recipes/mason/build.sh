#!/bin/bash

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

for i in $binaries; do cp $SRC_DIR/bin/$i $PREFIX/bin/$i && chmod a+x $PREFIX/bin/$i; done
