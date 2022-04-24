#!/bin/bash

LIBS="${LDFLAGS}" make -j4 CC="${CC}" CXX="${CXX}" multi

mkdir -p $PREFIX/bin
cp bwa-meme* $PREFIX/bin

cd RMI && cargo build --release && cd ..
cp RMI/target/release/bwa-meme-train-prmi $PREFIX/bin
cp build_rmis_dna.sh $PREFIX/bin
