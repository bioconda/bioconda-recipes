#!/bin/bash

binaries="\
prinseq-lite.pl \
prinseq-graphs-noPCA.pl \
"

mkdir -p $PREFIX/bin
for i in $binaries; do sed -i.bak 's|usr/bin/perl|usr/bin/env perl|' $i && cp $SRC_DIR/$i $PREFIX/bin && chmod +x $PREFIX/bin/$i; done
