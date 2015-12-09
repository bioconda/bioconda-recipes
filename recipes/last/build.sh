#!/bin/bash

export PRFX=$PREFIX

binaries="\
lastal \
lastdb \
last-split \
last-pair-probs \
last-merge-batches \
"

scripts=" \
maf-convert \
maf-join \
last-train \
last-postmask \
last-map-probs \
last-dotplot \
"

for i in $scripts; do 2to3 $SRC_DIR/scripts/$i -w --no-diffs &&  sed -i -- 's/string.maketrans("", "")/None/g' $SRC_DIR/scripts/$i && sed -i -- 's/#! \/usr\/bin\/env python/#! \/usr\/bin\/env python\'$'\n''from __future__ import print_function/g' && chmod +x $PREFIX/scripts/$i; done

chmod +x $SRC_DIR/build/*
make

mkdir -p $PREFIX/bin
for i in $binaries; do cp $SRC_DIR/src/$i $PREFIX/bin && chmod +x $PREFIX/bin/$i; done
make install prefix=$PREFIX # to install scripts, primarily
