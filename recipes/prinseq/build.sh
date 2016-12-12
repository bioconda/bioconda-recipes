#!/bin/bash

binaries="\
prinseq-lite.pl \
prinseq-graphs.pl \
prinseq-graphs-noPCA.pl \
"

mkdir -p $PREFIX/bin
for i in $binaries; do cp $SRC_DIR/$i $PREFIX/bin && chmod +x $PREFIX/bin/$i; done
