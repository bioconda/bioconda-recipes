#!/bin/bash

export PRFX=$PREFIX

binaries="\
lastal \
lastdb \
last-split \
lastal8 \
lastdb8 \
last-split8 \
last-pair-probs \
last-merge-batches \
"

scripts=" \
maf-sort \
maf-convert \
maf-join \
last-train \
last-postmask \
last-map-probs \
last-dotplot \
"

for i in $scripts; do cp $SRC_DIR/scripts/$i $PREFIX/bin && chmod +x $PREFIX/bin/$i; done

chmod +x $SRC_DIR/build/*
pushd src
make CXX="$CXX" CXXFLAGS="${CXXFLAGS}" CFLAGS="${CFLAGS}" LDFLAGS="-L${PREFIX}/lib -lz"
popd

mkdir -p $PREFIX/bin
for i in $binaries; do cp $SRC_DIR/src/$i $PREFIX/bin && chmod +x $PREFIX/bin/$i; done
make install prefix=$PREFIX # to install scripts, primarily
